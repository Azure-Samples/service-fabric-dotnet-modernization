using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Threading.Tasks;
using System.Threading;
using System.Diagnostics;

namespace app01.Controllers
{
    public class HomeController : Controller
    {
        private static int Fac(int n)
        {
            if (n > 1)
            {
                return n * Fac(n - 1);
            }
            else
            {
                return 1;
            }
        }
        private static int CpuTime()
        {
            return
            (int)Process.GetCurrentProcess().TotalProcessorTime.TotalMilliseconds;
        }
        private static long WallTime()
        {
            return DateTime.Now.Ticks / 10000;
        }
        private static void Load(double target)
        {
            int n = 1000000;
            int cpu = CpuTime();
            long wall = WallTime();
            int dcpu;
            long dwall;
            for (int i = 0; i < n; i++)
            {
                if (Fac(10) != 3628800)
                {
                    Environment.Exit(1);
                }
            }
            //Thread.Sleep(100);
            int cpu2 = CpuTime();
            long wall2 = WallTime();
            dcpu = cpu2 - cpu;
            dwall = wall2 - wall;
            n = (int)(n * ((target * dwall) / dcpu));
            //Console.WriteLine(dcpu + " " + dwall);
            cpu = cpu2;
            wall = wall2;
        }

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            //for (int i = 0; i < 20; i++)
            //    Load(1);

            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            //for (int i = 0; i < 20; i++)
            //    Load(1);

            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}