class Mono3 < Formula
  desc "Cross platform, open source .NET development framework"
  homepage "http://www.mono-project.com/"
  url "http://download.mono-project.com/sources/mono/mono-3.12.1.tar.bz2"
  sha256 "5d8cf153af2948c06bc9fbf5088f6834868e4db8e5f41c7cff76da173732b60d"

  bottle do
    rebuild 1
    sha256 "5198e039dd51649c18bf061ddd7ce9d340b7eb789b89cb5576859f136f25c9a4" => :yosemite
    sha256 "42e7f3a352274350abdd8ca174fe35d565b5dde77b25f5e6626a7322c3177eab" => :mavericks
    sha256 "5843d8e66bb316c2fbd8fa509923082d2cbbc5d44c76e54c82006bed582cb5dd" => :mountain_lion
  end

  keg_only "Conflicts with mono in main repository."

  # xbuild requires the .exe files inside the runtime directories to
  # be executable
  skip_clean "lib/mono"

  resource "monolite" do
    url "http://storage.bos.xamarin.com/mono-dist-master/cb/cb33b94c853049a43222288ead1e0cb059b22783/monolite-111-latest.tar.gz"
    sha256 "a957383beb5a7b6fbe39f7cc9a67a7eb2908b7aadc3f4bacee7853dfeed84dfb"
  end

  def install
    # a working mono is required for the the build - monolite is enough
    # for the job
    (buildpath/"mcs/class/lib/monolite").install resource("monolite")

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-nls=no
    ]

    args << "--build=" + (MacOS.prefer_64_bit? ? "x86_64": "i686") + "-apple-darwin"

    system "./configure", *args
    system "make"
    system "make", "install"
    # mono-gdb.py and mono-sgen-gdb.py are meant to be loaded by gdb, not to be
    # run directly, so we move them out of bin
    libexec.install bin/"mono-gdb.py", bin/"mono-sgen-gdb.py"
  end

  def caveats; <<-EOS.undent
    To use the assemblies from other formulae you need to set:
      export MONO_GAC_PREFIX="#{HOMEBREW_PREFIX}"
    EOS
  end

  test do
    test_str = "Hello Homebrew"
    test_name = "hello.cs"
    (testpath/test_name).write <<-EOS.undent
      public class Hello1
      {
         public static void Main()
         {
            System.Console.WriteLine("#{test_str}");
         }
      }
    EOS
    shell_output "#{bin}/mcs #{test_name}"
    output = shell_output "#{bin}/mono hello.exe"
    assert_match test_str, output.strip

    # Tests that xbuild is able to execute lib/mono/*/mcs.exe
    (testpath/"test.csproj").write <<-EOS.undent
      <?xml version="1.0" encoding="utf-8"?>
      <Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
        <PropertyGroup>
          <AssemblyName>HomebrewMonoTest</AssemblyName>
        </PropertyGroup>
        <ItemGroup>
          <Compile Include="#{test_name}" />
        </ItemGroup>
        <Import Project="$(MSBuildBinPath)\\Microsoft.CSharp.targets" />
      </Project>
    EOS
    shell_output "#{bin}/xbuild test.csproj"
  end
end
