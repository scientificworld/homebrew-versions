class ClangFormat38 < Formula
  desc "Formatting tools for C, C++, ObjC, Java, JavaScript, TypeScript"
  homepage "http://clang.llvm.org/docs/ClangFormat.html"
  url "http://llvm.org/releases/3.8.0/llvm-3.8.0.src.tar.xz"
  sha256 "555b028e9ee0f6445ff8f949ea10e9cd8be0d084840e21fbbe1d31d51fc06e46"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "35469b903414f1e7ed7870a6976379250fc1a3708d4b5ade5a5f20fabded46bf" => :sierra
    sha256 "02fec3b31622f0eda3706e72f43b608e0d9c399b9fd6ff45e07e541e3c0862e3" => :el_capitan
    sha256 "17a00b6ddc1c3f427702460a372c9d6ba8b51113a9c9a6f2e02f8dff1d485287" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "subversion" => :build

  conflicts_with "clang-format", :because => "Differing versions of the same formula"

  resource "clang" do
    url "http://llvm.org/releases/3.8.0/cfe-3.8.0.src.tar.xz"
    sha256 "04149236de03cf05232d68eb7cb9c50f03062e339b68f4f8a03b650a11536cf9"
  end

  resource "libcxx" do
    url "http://llvm.org/releases/3.8.0/libcxx-3.8.0.src.tar.xz"
    sha256 "36804511b940bc8a7cefc7cb391a6b28f5e3f53f6372965642020db91174237b"
  end

  def install
    (buildpath/"projects/libcxx").install resource("libcxx")
    (buildpath/"tools/clang").install resource("clang")

    mkdir "build" do
      args = std_cmake_args
      args << "-DLLVM_ENABLE_LIBCXX=ON"
      args << ".."
      system "cmake", "-G", "Ninja", *args
      system "ninja", "clang-format"
      bin.install "bin/clang-format"
    end
    bin.install "tools/clang/tools/clang-format/git-clang-format"
    (share/"clang").install Dir["tools/clang/tools/clang-format/clang-format*"]
  end

  test do
    # NB: below C code is messily formatted on purpose.
    (testpath/"test.c").write <<-EOS
      int         main(char *args) { \n   \t printf("hello"); }
    EOS

    assert_equal "int main(char *args) { printf(\"hello\"); }\n",
        shell_output("#{bin}/clang-format -style=Google test.c")
  end
end
