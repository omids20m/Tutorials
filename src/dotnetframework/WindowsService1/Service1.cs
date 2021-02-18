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
            var logDir = System.Configuration.ConfigurationManager.AppSettings["LogFilePath"].ToString();

            if (Environment.UserInteractive)
            {
                LogService("I'm running from console");

                LogService("Log directory is on " + logDir);

                var service = new Service1();
                service.OnStart(new string[] { "" });

                LogService("Press any key to exit ...");

                Console.ReadLine();
                service.OnStop();
            }
            else
            {
                var service = new Service1();
                Run(service);

                //ServiceBase[] ServicesToRun;
                //ServicesToRun = new ServiceBase[]
                //{
                //    new Service1()
                //};
                //ServiceBase.Run(ServicesToRun);
            }
        }

        public Service1()
        {
            InitializeComponent();
            timeDelay = new System.Timers.Timer();
            timeDelay.Interval = int.Parse(System.Configuration.ConfigurationManager.AppSettings["Interval"].ToString());
            //timeDelay.Interval = 5000;
            timeDelay.Elapsed += new System.Timers.ElapsedEventHandler(WorkProcess);
        }
        public void WorkProcess(object sender, System.Timers.ElapsedEventArgs e)
        {
            string process = " Timer Tick " + count;
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
                Console.WriteLine(DateTime.Now.ToString() + " " + content);
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
