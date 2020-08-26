class Giflib5 < Formula
  desc "Library and utilities for processing GIFs"
  homepage "http://giflib.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/giflib/giflib-5.1.3.tar.bz2"
  sha256 "5096d27805283599b01074d487ad3f8e02bd26b84d759b9017be876ca3d5b81d"

  bottle do
    cellar :any
    sha256 "2cd4acd853d02b17d3a2b6aeacd6cfb86d1c7169d9bcecdad8c1bb1b45478f75" => :el_capitan
    sha256 "ad28823dd73acd53bbcb1cf65937914fd7bd7ebf06404de04865b4d48f0484cc" => :yosemite
    sha256 "c5209430a970ba85bdccb634b2b144d71a33078a4396623567b45606b57569db" => :mavericks
  end

  keg_only "Conflicts with giflib in main repository."

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    assert_match /Screen Size - Width = 1, Height = 1/, shell_output("#{bin}/giftext #{test_fixtures("test.gif")}")
  end
end
