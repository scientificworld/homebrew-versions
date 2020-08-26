class Bison27 < Formula
  desc "Parser generator"
  homepage "https://www.gnu.org/software/bison/"
  url "https://ftpmirror.gnu.org/bison/bison-2.7.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/bison/bison-2.7.1.tar.gz"
  sha256 "08e2296b024bab8ea36f3bb3b91d071165b22afda39a17ffc8ff53ade2883431"

  bottle do
    rebuild 1
    sha256 "f0c9fbb8b8734b1fe48ee8fc7ee3b272262d2eadcc4e233231b8e8312ff1578f" => :yosemite
    sha256 "510a8e77cfdf4a0be5be12d4558dcd5bdbcf61ec6808118edcfd8bd3a34799cc" => :mavericks
    sha256 "f024ef74d444814e115883a615ba1b67aa38e063533e27f33db2e6e15e9f0090" => :mountain_lion
  end

  keg_only :provided_by_osx, "Some formulae require a newer version of bison."

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
