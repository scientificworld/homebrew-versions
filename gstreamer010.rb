class Gstreamer010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-0.10.36.tar.bz2"
  sha256 "e556a529e0a8cf1cd0afd0cab2af5488c9524e7c3f409de29b5d82bb41ae7a30"

  bottle do
    sha256 "2d305985473d2ee608f04e28198b4231cba5c1086ee54bf9bbfb1e01c191aae7" => :yosemite
    sha256 "d86e6b0320b8938ddb393f1786fa97773867584d205af43ea26c383dfbe793e5" => :mavericks
    sha256 "93b0ef760f8d1a8971689ca83adb7acef0a5904fe262f537f27bbd730ed2b814" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "libxml2" # w/o: "error: Could not link libxml2 test program"

  # Fix sed version detection for 10.8
  # Reported and fixed upstream:
  # https://bugzilla.gnome.org/show_bug.cgi?id=680428
  patch :DATA

  def install
    # Look for plugins in HOMEBREW_PREFIX/lib/gstreamer-0.10 instead of
    # HOMEBREW_PREFIX/Cellar/gstreamer/0.10/lib/gstreamer-0.10, so we'll find
    # plugins installed by other packages without setting GST_PLUGIN_PATH in
    # the environment.
    inreplace "configure", 'PLUGINDIR="$full_var"',
      "PLUGINDIR=\"#{HOMEBREW_PREFIX}/lib/gstreamer-0.10\""

    ENV.append "CFLAGS", "-funroll-loops -fstrict-aliasing -fno-common"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-introspection=no"
    system "make"
    system "make", "install"
  end
end

__END__
diff --git a/configure b/configure
index 0af896d..20e6576 100755
--- a/configure
+++ b/configure
@@ -21304,7 +21304,7 @@ fi
   fi
 
         flex_min_version=2.5.31
-  flex_version=`$FLEX_PATH --version | head -n 1 | sed 's/^.* //' | sed 's/[a-zA-Z]*$//' | cut -d' ' -f1`
+  flex_version=`$FLEX_PATH --version | head -n 1 | awk '{print $2'}`
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking flex version $flex_version >= $flex_min_version" >&5
 $as_echo_n "checking flex version $flex_version >= $flex_min_version... " >&6; }
   if perl -w <<EOF
diff --git a/gst/gstdatetime.c b/gst/gstdatetime.c
index 60f709f..cdc7e75 100644
--- a/gst/gstdatetime.c
+++ b/gst/gstdatetime.c
@@ -21,8 +21,8 @@
 #include "config.h"
 #endif
 
-#include "glib-compat-private.h"
 #include "gst_private.h"
+#include "glib-compat-private.h"
 #include "gstdatetime.h"
 #include <glib.h>
 #include <math.h>
