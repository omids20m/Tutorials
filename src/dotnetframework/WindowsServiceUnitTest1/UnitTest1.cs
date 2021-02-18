using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Diagnostics.CodeAnalysis;

namespace WindowsService1.UnitTest
{
    [TestClass]
    [ExcludeFromCodeCoverage]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {
            Assert.IsTrue(true);
        }
        [TestMethod]
        public void TestMethod2()
        {
            Assert.IsTrue(true);
        }
        [TestMethod]
        public void TestMethodFail1()
        {
            Assert.IsTrue(true);
        }
    }
}
