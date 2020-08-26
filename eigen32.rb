class Eigen32 < Formula
  desc "C++ template library for linear algebra"
  homepage "https://eigen.tuxfamily.org/"
  url "https://bitbucket.org/eigen/eigen/get/3.2.10.tar.bz2"
  sha256 "760e6656426fde71cc48586c971390816f456d30f0b5d7d4ad5274d8d2cb0a6d"

  bottle do
    cellar :any_skip_relocation
    sha256 "89ecd58783c9750b3d9122cce786fb17834d108fd3e51247255d8094f9bd16e7" => :sierra
    sha256 "c57f778c3143aad316232c46232a7d304c497e7923cb1a1fe2604fda8302bb44" => :el_capitan
    sha256 "ef12ccf9d0cceab10bc57cb23a5723de78c69a74e44f5a01ce16075d20068f83" => :yosemite
  end

  keg_only "Conflicts wit eigen in core repository."

  option :universal

  depends_on "cmake" => :build

  def install
    ENV.universal_binary if build.universal?

    mkdir "eigen-build" do
      args = std_cmake_args
      args << "-Dpkg_config_libdir=#{lib}" << ".."
      system "cmake", *args
      system "make", "install"
    end
    (share/"cmake/Modules").install "cmake/FindEigen3.cmake"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include <Eigen/Dense>
      using Eigen::MatrixXd;
      int main()
      {
        MatrixXd m(2,2);
        m(0,0) = 3;
        m(1,0) = 2.5;
        m(0,1) = -1;
        m(1,1) = m(1,0) + m(0,1);
        std::cout << m << std::endl;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}/eigen3", "-o", "test"
    assert_equal %w[3 -1 2.5 1.5], shell_output("./test").split
  end
end
