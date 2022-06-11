using System;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace WindowsService1
{
    public partial class Service1 : ServiceBase
    {
        System.Timers.Timer timeDelay;
        int count;

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main()
        {
            var environment = System.Configuration.ConfigurationManager.AppSettings["Environment"].ToString();
            var logFilePath = System.Configuration.ConfigurationManager.AppSettings["LogFilePath"].ToString();

            LogService(String.Format("Environment:   '{0}'", environment));
            LogService(String.Format("Log file path: '{0}'", logFilePath));

            if (Environment.UserInteractive)
            {
                LogService("Running mode:  'Interactive'");

                var service = new Service1();
                service.OnStart(new string[] { "" });

                LogService("NOTE: You can press any key at any time to exit ...");

                Console.ReadLine();
                service.OnStop();
            }
            else
            {
                LogService("Running mode:  'As a Service'");
                var service = new Service1();
                Run(service);
            }
        }

        public Service1()
        {
            InitializeComponent();
            timeDelay = new System.Timers.Timer();
            timeDelay.Interval = 
                int.Parse(System.Configuration.ConfigurationManager.AppSettings["Interval"].ToString());
            LogService(String.Format("Timer interval: {0} milliseconds", timeDelay.Interval));
            timeDelay.Elapsed += new System.Timers.ElapsedEventHandler(WorkProcess);
        }

        public void WorkProcess(object sender, System.Timers.ElapsedEventArgs e)
        {
            string process = "Timer Tick: " + count;
            LogService(process);
            count++;
        }

        protected override void OnStart(string[] args)
        {
            LogService("Service is Started");
            timeDelay.Enabled = true;
        }

        protected override void OnStop()
        {
            LogService("Service Stoped");
            timeDelay.Enabled = false;
        }

        private static void LogService(string content)
        {
            if (Environment.UserInteractive)
            {
                Console.WriteLine(DateTime.Now.ToString() + " - " + content);
            }

            var logDir = System.Configuration.ConfigurationManager.AppSettings["LogFilePath"].ToString();
            FileStream fs = new FileStream(logDir, FileMode.OpenOrCreate, FileAccess.ReadWrite);
            StreamWriter sw = new StreamWriter(fs);
            sw.BaseStream.Seek(0, SeekOrigin.End);
            sw.WriteLine(DateTime.Now.ToString() + " " + content);
            sw.Flush();
            sw.Close();
        }
    }
}
