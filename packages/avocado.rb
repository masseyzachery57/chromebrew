require 'package'

class Avocado < Package
  description 'Avocado is a next generation testing framework inspired by Autotest and modern development tools such as git.'
  homepage 'http://avocado-framework.github.io/'
  version '57.0'
  source_url 'https://github.com/avocado-framework/avocado/archive/57.0.tar.gz'
  source_sha256 'c49fdf0946eed445fd8397354db3491869389ed4578ba477d447f105c99f15e4'

  binary_url ({
  })
  binary_sha256 ({
  })

  depends_on 'python27' unless File.exists? "#{CREW_PREFIX}/bin/pip"
  depends_on 'xzutils'

  def self.install
    system "pip install avocado-framework --root #{CREW_DEST_PREFIX} --prefix #{CREW_DEST_PREFIX}"
    system "pip install -r https://raw.githubusercontent.com/avocado-framework/avocado/master/requirements.txt --root #{CREW_DEST_PREFIX} --prefix #{CREW_DEST_PREFIX}"
    system "mv #{CREW_DEST_PREFIX}/usr/libexec #{CREW_DEST_PREFIX}"
    system "mv #{CREW_DEST_PREFIX}/usr/share #{CREW_DEST_PREFIX}"
    system "mv #{CREW_DEST_PREFIX}#{CREW_DEST_PREFIX}/* #{CREW_DEST_PREFIX}"
    system "rm -rf #{CREW_DEST_PREFIX}#{CREW_PREFIX}/tmp"
    system "mkdir -p $HOME/.config/avocado"
    system "ln -s #{CREW_PREFIX}/etc/avocado/avocado.conf $HOME/.config/avocado/avocado.conf"
    system "mkdir -p #{CREW_DEST_DIR}/$HOME/.config/avocado"
    system "ln -s #{CREW_PREFIX}/etc/avocado/avocado.conf #{CREW_DEST_DIR}/$HOME/.config/avocado/avocado.conf"
  end
end
