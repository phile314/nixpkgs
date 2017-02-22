{ stdenv, fetchurl, makeWrapper, jre, utillinux, getopt }:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "5.2.1";
  name = "elasticsearch-${version}";

  src = fetchurl {
    url = "https://artifacts.elastic.co/downloads/elasticsearch/${name}.tar.gz";
    sha256 = "0xa416cchksjdpzmcvr15hk9mqny5m54ffh6qvwbqsw9p35zx2zj";
  };

  patches = [ ./es-home-5.x.patch ./es-classpath-5.x.patch ];

  buildInputs = [ makeWrapper jre ] ++
    (if (!stdenv.isDarwin) then [utillinux] else [getopt]);

  installPhase = ''
    mkdir -p $out
    cp -R bin config lib modules $out

    wrapProgram $out/bin/elasticsearch \
      --prefix ES_CLASSPATH : "$out/lib/${name}.jar":"$out/lib/*" \
      ${if (!stdenv.isDarwin)
        then ''--prefix PATH : "${utillinux}/bin/"''
        else ''--prefix PATH : "${getopt}/bin"''} \
      --set JAVA_HOME "${jre}"
    wrapProgram $out/bin/elasticsearch-plugin --set JAVA_HOME "${jre}"
  '';

  meta = {
    description = "Open Source, Distributed, RESTful Search Engine";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = [
      maintainers.offline
      maintainers.markWot
    ];
  };
}
