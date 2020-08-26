class Go14 < Formula
  desc "Go programming environment (1.4)"
  homepage "https://golang.org"
  url "https://storage.googleapis.com/golang/go1.4.3.src.tar.gz"
  mirror "https://fossies.org/linux/misc/go1.4.3.src.tar.gz"
  version "1.4.3"
  sha256 "9947fc705b0b841b5938c48b22dc33e9647ec0752bae66e50278df4f23f64959"

  bottle do
    rebuild 1
    sha256 "cb0b484f72595448782f9310cc20ee232ec995d8bc2f526f2f8dc3db5067ca59" => :el_capitan
    sha256 "fbc83a42718bd0fbb64261e90eb6f9f7149645edf3404cd0109b4479be88162e" => :yosemite
    sha256 "171aa236e64a1e67d181da21cdb24beb14cb2505647c748a73f78f5753c677e6" => :mavericks
  end

  option "with-cc-all", "Build with cross-compilers and runtime support for all supported platforms"
  option "with-cc-common", "Build with cross-compilers and runtime support for darwin, linux and windows"
  option "without-cgo", "Build without cgo"
  option "without-godoc", "godoc will not be installed for you"
  option "without-vet", "vet will not be installed for you"

  resource "gotools" do
    url "https://go.googlesource.com/tools.git",
    :revision => "69db398fe0e69396984e3967724820c1f631e971"
  end

  resource "gobootstrap" do
    if MacOS.version > :lion
      url "https://storage.googleapis.com/golang/go1.4.2.darwin-amd64-osx10.8.tar.gz"
      sha256 "c2f53983fc8fe5159d811081022ebc401b8111759ce008f91193abdae82cdbc9"
    else
      url "https://storage.googleapis.com/golang/go1.4.2.darwin-amd64-osx10.6.tar.gz"
      sha256 "da40e85a2c9bda9d2c29755c8b57b8d5932440ba466ca366c2a667697a62da4c"
    end
  end

  def install
    ENV.refurbish_args

    # host platform (darwin) must come last in the targets list
    if build.with? "cc-all"
      targets = [
        ["linux",   ["386", "amd64", "arm"]],
        ["freebsd", ["386", "amd64", "arm"]],
        ["netbsd",  ["386", "amd64", "arm"]],
        ["openbsd", ["386", "amd64"]],
        ["windows", ["386", "amd64"]],
        ["dragonfly", ["386", "amd64"]],
        ["plan9",   ["386", "amd64"]],
        ["solaris", ["amd64"]],
        ["darwin",  ["386", "amd64"]],
      ]
    elsif build.with? "cc-common"
      targets = [
        ["linux",   ["386", "amd64", "arm"]],
        ["windows", ["386", "amd64"]],
        ["darwin",  ["386", "amd64"]],
      ]
    else
      targets = [["darwin", [""]]]
    end

    cd "src" do
      targets.each do |os, archs|
        cgo_enabled = os == "darwin" && build.with?("cgo") ? "1" : "0"
        archs.each do |arch|
          ENV["GOROOT_FINAL"] = libexec
          ENV["GOOS"]         = os
          ENV["GOARCH"]       = arch
          ENV["CGO_ENABLED"]  = cgo_enabled
          ohai "Building go for #{arch}-#{os}"
          system "./make.bash", "--no-clean"
        end
      end
    end

    (buildpath/"pkg/obj").rmtree
    rm_rf "gobootstrap" # Bootstrap not required beyond compile.
    libexec.install Dir["*"]
    (bin/"go14").write_env_script(libexec/"bin/go", :PATH => "#{libexec}/bin:$PATH")
    bin.install_symlink libexec/"bin/gofmt" => "gofmt14"

    if build.with?("godoc") || build.with?("vet")
      ENV.prepend_path "PATH", libexec/"bin"
      ENV["GOPATH"] = buildpath
      (buildpath/"src/golang.org/x/tools").install resource("gotools")

      if build.with? "godoc"
        cd "src/golang.org/x/tools/cmd/godoc/" do
          system "go", "build"
          (libexec/"bin").install "godoc"
        end
        bin.install_symlink libexec/"bin/godoc" => "godoc14"
      end

      if build.with? "vet"
        cd "src/golang.org/x/tools/cmd/vet/" do
          system "go", "build"
          # This is where Go puts vet natively; not in the bin.
          (libexec/"pkg/tool/darwin_amd64/").install "vet"
        end
      end
    end
  end

  def caveats; <<-EOS.undent
    The `go*` commands in `bin` are suffixed with 14 e.g. `go14`.

    As of go 1.2, a valid GOPATH is required to use the `go get` command:
      https://golang.org/doc/code.html#GOPATH

    You may wish to add the GOROOT-based install location
    (with unsuffixed `go*` commands) to your PATH:
      export PATH=$PATH:#{opt_libexec}/bin
    EOS
  end

  test do
    (testpath/"hello.go").write <<-EOS.undent
    package main

    import "fmt"

    func main() {
        fmt.Println("Hello World")
    }
    EOS
    # Run go fmt check for no errors then run the program.
    # This is a a bare minimum of go working as it uses fmt, build, and run.
    system "#{bin}/go14", "fmt", "hello.go"
    assert_equal "Hello World\n", shell_output("#{bin}/go14 run hello.go")

    if build.with? "godoc"
      assert File.exist?(libexec/"bin/godoc")
      assert File.executable?(libexec/"bin/godoc")
    end

    if build.with? "vet"
      assert File.exist?(libexec/"pkg/tool/darwin_amd64/vet")
      assert File.executable?(libexec/"pkg/tool/darwin_amd64/vet")
    end
  end
end
