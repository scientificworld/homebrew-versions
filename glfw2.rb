class Glfw2 < Formula
  homepage "http://www.glfw.org/"
  url "https://downloads.sourceforge.net/project/glfw/glfw/2.7.9/glfw-2.7.9.tar.bz2"
  sha256 "d1f47e99e4962319f27f30d96571abcb04c1022c000de4d01df69ec59aae829d"

  bottle do
    cellar :any
    sha256 "e8671d6afb9e92f0aa692997a7fce65fcbd686e4e1762d4afc546542bead8211" => :yosemite
    sha256 "c13596bfe24aabf4b717f95ee6a3d8e9103b2122a614b7cc0d011d0570487ea3" => :mavericks
    sha256 "3b140b354f00889733aec1ec6cc5f076efba28630fab44435e31c3b1dd108aa1" => :mountain_lion
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "make", "PREFIX=#{prefix}", "cocoa-dist-install"
  end
end
