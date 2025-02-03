using System.Management;
using System.Linq;
using System.Net.Http;
using System.Security.Policy;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace WinMainForm
{
    public partial class Form1 : Form
    {
        [DllImport("PiDll.dll", CallingConvention = CallingConvention.Cdecl)]
        unsafe public extern static double PiGPU(int iter);
        [DllImport("PiDll.dll", CharSet = CharSet.Ansi)]
        unsafe public extern static char GPUInfo();
        public Form1()
        {
            InitializeComponent();
            FileSystemWatcher watcher = new FileSystemWatcher(Application.StartupPath, "test.txt");
            watcher.NotifyFilter = NotifyFilters.Attributes

                     | NotifyFilters.LastWrite;

            watcher.EnableRaisingEvents = true;
            watcher.Changed += OnChanged;
        }

        private void OnChanged(object sender, FileSystemEventArgs e)
        {
            try
            {

                string str = ChangeInFile(Application.StartupPath + @"test.txt");
                // string[] s = str.ToString();
                //  button2.BeginInvoke((MethodInvoker)(() => button2.Enabled = true));
                richTextBox1.BeginInvoke((MethodInvoker)(() =>
                {
                    richTextBox1.Text += str;
                }));
            }
            catch (ArgumentException)
            {
                return;
            }
        }
        private string ChangeInFile(string filename)
        {
            Thread.Sleep(10);
            using (StreamReader fin = new StreamReader(filename))
            {
                return fin.ReadToEnd();
            }
        }
        Int64 n = 0;
        private void button1_Click(object sender, EventArgs e)
        {
            textBox2.Text = "";
            n = Convert.ToInt64(textBox1.Text);
            textBox2.Text += "Количество ядер = " + Environment.ProcessorCount.ToString() + Environment.NewLine;
            Task.Run(() => Calculate(n));
            //await Raschet(MyIter1);
            var s = new ManagementObjectSearcher(@"SELECT * FROM Win32_processor");
            foreach (ManagementObject obj in s.Get().OfType<ManagementObject>())
            {
                textBox2.Text += "Частота процессора (МГц) = " + obj["CurrentClockSpeed"] + Environment.NewLine;// "Частота процессора = " + o["CurrentClockSpeed"];
            }

            //var o = s.Get().OfType<ManagementObject>().First();
            //textBox2.Text += "Частота процессора = " + o["CurrentClockSpeed"];
        }
        long IterVPotoke = 0;
        private void Calculate(long nn)
        {
            Stopwatch stopwatch = new Stopwatch();
            stopwatch.Start();
            int cores = Environment.ProcessorCount;
            IterVPotoke = Convert.ToInt64(nn / cores);
            double resultPiCalc = 0d;
            Task<double>[] Mytasks = new Task<double>[cores];
            for (int i = 0; i < cores; i++)
            {
                int id = i;
                Mytasks[id] = Task.Run(() => Picalc(id));
            }
            for (int i = 0; i < cores; i++)
            {
                resultPiCalc += Mytasks[i].Result;
            }
            stopwatch.Stop();
            textBox2.BeginInvoke((MethodInvoker)(() => textBox2.Text += "Число Пи = " + resultPiCalc.ToString() + Environment.NewLine));
            textBox2.BeginInvoke((MethodInvoker)(() => textBox2.Text += "Затрачено времени (мс) = " + stopwatch.ElapsedMilliseconds.ToString() + Environment.NewLine));
        }

        private double Picalc(int obj)
        {
            long leftiterlocal = (IterVPotoke * obj);
            long rightiterlocal = (IterVPotoke * (obj + 1)) - 1;
            double pilocal = 0d;
            for (long k = leftiterlocal; k <= rightiterlocal; k++)
            {
                //enumber *= Math.Pow(2, Math.Pow((Math.Log(2) - 1), 2 * k)) / Math.Pow(2, Math.Pow((Math.Log(2) - 1), 2 * k - 1));
                pilocal += 4 / (4 * (double)k + 1) - 4 / (4 * (double)k + 3);
            }
            return pilocal;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            richTextBox1.Text = " ";
            textBox3.Text = "";
            int n = Convert.ToInt32(textBox1.Text);
            Task.Run(() => CalculateGPU(n));
            //textBox3.Text += deviseProp() + Environment.NewLine;
        }

        private void CalculateGPU(int n)
        {
            string s1 = "Информация о видеокарте: ";
            // 
            using (var searcher = new ManagementObjectSearcher("select * from Win32_VideoController"))
            {
                foreach (ManagementObject obj in searcher.Get())
                {
                    s1 += ("Name  -  " + obj["Name"] + "</br>");
                    /* s1 += ("DeviceID  -  " + obj["DeviceID"] + "</br>");
                     s1 += ("AdapterRAM  -  " + obj["AdapterRAM"] + "</br>");
                     s1 += ("AdapterDACType  -  " + obj["AdapterDACType"] + "</br>");
                     s1 += ("Monochrome  -  " + obj["Monochrome"] + "</br>");
                     s1 += ("InstalledDisplayDrivers  -  " + obj["InstalledDisplayDrivers"] + "</br>");
                     s1 += ("DriverVersion  -  " + obj["DriverVersion"] + "</br>");
                     s1 += ("VideoProcessor  -  " + obj["VideoProcessor"] + "</br>");
                     s1 += ("VideoArchitecture  -  " + obj["VideoArchitecture"] + "</br>");
                     s1 += ("VideoMemoryType  -  " + obj["VideoMemoryType"] + "</br>");*/
                }
            }
            textBox3.BeginInvoke((MethodInvoker)(() => textBox3.Text += s1 + Environment.NewLine));
            GPUInfo();
            Stopwatch stopwatch = new Stopwatch();
            stopwatch.Start();
            double pi = PiGPU(n);
            stopwatch.Stop();
            textBox3.BeginInvoke((MethodInvoker)(() => textBox3.Text += "Число Пи = " + pi.ToString() + Environment.NewLine));
            textBox3.BeginInvoke((MethodInvoker)(() => textBox3.Text += "Затрачено времени (мс) = " + stopwatch.ElapsedMilliseconds.ToString() + Environment.NewLine));
        }
    }
}