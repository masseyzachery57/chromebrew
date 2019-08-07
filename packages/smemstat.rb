require 'package'

class Smemstat < Package
  description 'Smemstat reports the physical memory usage taking into consideration shared memory.'
  homepage 'http://kernel.ubuntu.com/~cking/smemstat/'
  version '0.02.04'
  source_url 'https://kernel.ubuntu.com/~cking/tarballs/smemstat/smemstat-0.02.04.tar.xz'
  source_sha256 '108c2d76da762c9d8c50d87b3a58f3b4e44858dd8961a1f2681faa37aca56dce'

  binary_url ({
  })
  binary_sha256 ({
  })

  depends_on 'ncurses'

  def self.build
    system "sed -i 's,/usr,#{CREW_PREFIX},g' Makefile"
    system "sed -i '/^CFLAGS += -Wall/s/$/ -I\\/usr\\/local\\/include\\/ncurses/' Makefile"
    system "make"
  end

  def self.install
    system "make", "DESTDIR=#{CREW_DEST_DIR}", "install"
  end
end
