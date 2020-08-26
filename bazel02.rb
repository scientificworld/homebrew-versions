class Bazel02 < Formula
  desc "Google's own build tool"
  homepage "http://bazel.io/"
  url "https://github.com/bazelbuild/bazel/archive/0.2.3.tar.gz"
  sha256 "37fd2d49c57df171b704bf82c94e7bf954d94748e2a8621c5456c5c9d5f2c845"
  head "https://github.com/bazelbuild/bazel.git"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "dd12c3897c4c3b15db32c3afc276ac15fe0f60b30332abd91b6e043c3596f498" => :sierra
    sha256 "4f9b78abb455089ad65b3b70ac6a30f4248394a8563a80704164b645378657aa" => :el_capitan
    sha256 "c6ee3593f5c8eea5661588eff236b009ea0a09e1ee56d01edd48f39b2f7efdc7" => :yosemite
  end

  depends_on :java => "1.8+"
  depends_on :macos => :yosemite

  conflicts_with "bazel", :because => "Differing version of same formula"

  if MacOS.version >= :sierra
    # Use nanosleep(2) instead of poll(2) to sleep.
    patch do
      url "https://github.com/bazelbuild/bazel/pull/1803.patch"
      sha256 "a6673fb1875adec23630950d579a6ba11237045fb3c645cb4c690efd5b313986"
    end
  end

  def install
    ENV["EMBED_LABEL"] = "#{version}-homebrew"

    system "./compile.sh"
    system "./output/bazel", "build", "scripts:bash_completion"

    bin.install "output/bazel" => "bazel"
    bash_completion.install "bazel-bin/scripts/bazel-complete.bash"
    zsh_completion.install "scripts/zsh_completion/_bazel"
  end

  test do
    touch testpath/"WORKSPACE"

    (testpath/"ProjectRunner.java").write <<-EOS.undent
      public class ProjectRunner {
        public static void main(String args[]) {
          System.out.println("Hi!");
        }
      }
    EOS

    (testpath/"BUILD").write <<-EOS.undent
      java_binary(
        name = "bazel-test",
        srcs = glob(["*.java"]),
        main_class = "ProjectRunner",
      )
    EOS

    system "#{bin}/bazel", "build", "//:bazel-test"
    system "bazel-bin/bazel-test"
  end
end
