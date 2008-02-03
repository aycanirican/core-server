(in-package :core-server.test)

(defparameter *tinydns-data*
  ".core.gen.tr:139.179.139.251:a:259200
.core.gen.tr:212.175.40.11:b:259200
=node1.core.gen.tr:139.179.139.251:86400
=node2.core.gen.tr:212.175.40.11:86400
=node3.core.gen.tr:212.175.40.12:86400
+www.core.gen.tr:139.179.139.251:86400
+imap.core.gen.tr:212.175.40.11:86400
+smtp.core.gen.tr:212.175.40.11:86400
=zpam.core.gen.tr:212.175.40.55:86400
@core.gen.tr:212.175.40.55:a::86400
'core.gen.tr:v=spf1 a mx a\072node2.core.gen.tr a\072office1.core.gen.tr ~all:3600
+coretal.core.gen.tr:212.175.40.11:86400
+ns1.core.gen.tr:139.179.139.251:86400
+ns2.core.gen.tr:212.175.40.11:86400
+irc.core.gen.tr:139.179.139.251:86400
+wiki.core.gen.tr:212.175.40.12:86400
+priwiki.core.gen.tr:212.175.40.12:86400
+svn.core.gen.tr:139.179.139.251:86400
+cvs.core.gen.tr:139.179.139.251:86400
=zen.core.gen.tr:195.174.145.244:86400
+people.core.gen.tr:139.179.139.251:86400
+blogs.core.gen.tr:139.179.139.251:86400
+evrimulu.core.gen.tr:139.179.139.251:86400
+paketler.core.gen.tr:212.175.40.11:86400
.aytek.org:139.179.139.251:a:259200
.aytek.org:212.175.40.11:b:259200
+www.aytek.org:139.179.139.251:86400
.hackatronix.com:139.179.139.251:a:259200
.hackatronix.com:212.175.40.11:b:259200
+www.hackatronix.com:139.179.139.251:86400
.arslankardesler.com.tr:139.179.139.251:a:259200
.arslankardesler.com.tr:212.175.40.11:b:259200
.teargas.org:139.179.139.251:a:259200
.teargas.org:212.175.40.11:b:259200
=www.teargas.org:212.175.40.11:86400
+www.arslankardesler.com.tr:212.175.40.36:86400
+mail.arslankardesler.com.tr:212.175.40.36:86400
@arslankardesler.com.tr:212.175.40.36:a::86400
+mail.core.gen.tr:212.175.40.11:86400
@hackatronix.com:212.175.40.11:a::86400
#.karacadil.com.tr:139.179.139.251:a:259200
#.karacadil.com.tr:212.175.40.11:b:259200
#+www.karacadil.com.tr:212.175.40.11:86400
#@karacadil.com.tr:212.175.40.36:a::86400
#+mail.karacadil.com.tr:212.175.40.36:86400
.kulogluahsap.com:139.179.139.251:a:259200
.kulogluahsap.com:212.175.40.11:b:259200
@kulogluahsap.com:212.175.40.36:a::86400
+www.kulogluahsap.com:212.175.40.36:86400
+mail.kulogluahsap.com:212.175.40.36:86400
.meptasarim.net:139.179.139.251:a:259200
.meptasarim.net:212.175.40.11:b:259200
.cadilar.com:212.175.40.11:a:259200
.cadilar.com:139.179.139.251:b:259200
@meptasarim.net:212.175.40.36:a::86400
+www.meptasarim.net:212.175.40.36:86400
@cadilar.com:212.175.40.36:a::86400
+www.cadilar.com:212.175.40.36:86400
.hedee.com:139.179.139.251:a:259200
.hedee.com:212.175.40.11:b:259200
@hedee.com:212.175.40.11:a::86400
+www.hedee.com:212.175.40.11:86400
.dervisozer.com:139.179.139.251:a:259200
.dervisozer.com:212.175.40.11:b:259200
+www.dervisozer.com:212.175.40.11:86400
@dervisozer.com:212.175.40.11:a::86400
+ebooks.core.gen.tr:139.179.139.251:86400
+core.gen.tr:212.175.40.11:86400
=heechee.core.gen.tr:195.174.145.186:86400
+labs.core.gen.tr:139.179.139.251:86400
.ersoyemlak.com.tr:139.179.139.251:a:259200
.ersoyemlak.com.tr:212.175.40.11:b:259200
.ersoyinsaat.com.tr:139.179.139.251:a:259200
.ersoyinsaat.com.tr:212.175.40.11:b:259200
+www.ersoyemlak.com.tr:139.179.139.251:86400
+www.ersoyinsaat.com.tr:139.179.139.251:86400
.grafturk.com:139.179.139.251:a:259200
.grafturk.com:212.175.40.11:b:259200
+mail.grafturk.com:212.175.40.36:86400
+www.grafturk.com:212.175.40.36:86400
@grafturk.com:212.175.40.36:a::86400
+ederslik.com:212.175.40.12:86400
.ederslik.com:139.179.139.251:a:259200
.ederslik.com:212.175.40.11:b:259200
+www.ederslik.com:212.175.40.12:86400
.ebrualbayrak.com:139.179.139.251:a:259200
.ebrualbayrak.com:212.175.40.11:b:259200
.atilalbayrak.com:139.179.139.251:a:259200
.atilalbayrak.com:212.175.40.11:b:259200
+www.ebrualbayrak.com:212.175.40.36:86400
+www.atilalbayrak.com:212.175.40.36:86400
@ebrualbayrak.com:212.175.40.36:a::86400
@atilalbayrak.com:212.175.40.36:a::86400
.sentezarastirma.com:212.175.40.11:a:259200
.sentezarastirma.com:139.179.139.251:b:259200
+www.sentezarastirma.com:212.175.40.36:86400
@sentezarastirma.com:212.175.40.36:a::86400
+mail.sentezarastirma.com:212.175.40.36:86400
.biyoart.com.tr:139.179.139.251:a:259200
.biyoart.com.tr:212.175.40.11:b:259200
+www.biyoart.com.tr:212.175.40.36:86400
+mail.biyoart.com.tr:212.175.40.36:86400
@biyoart.com.tr:212.175.40.36:a::86400
=psyche.core.gen.tr:212.156.217.235:86400
=office1.core.gen.tr:88.249.13.201:86400
.caveti.com:139.179.139.251:a:259200
.caveti.com:212.175.40.11:b:259200
+www.caveti.com:212.175.40.11:86400
.kocademirler.com:139.179.139.251:a:259200
.kocademirler.com:212.175.40.11:b:259200
@kocademirler.com:212.175.40.36:a::86400
+www.kocademirler.com:212.175.40.36:86400
+mail.kocademirler.com:212.175.40.36:86400
.guzincanan.com:139.179.139.251:a:259200
.guzincanan.com:212.175.40.11:b:259200
@guzincanan.com:212.175.40.36:a::86400
+www.guzincanan.com:212.175.40.36:86400
+mail.guzincanan.com:212.175.40.36:86400
.adamsaat.com:139.179.139.251:a:259200
.adamsaat.com:212.175.40.11:b:259200
@adamsaat.com:212.175.40.55:a::86400
+www.adamsaat.com:212.175.40.11:86400
+mail.adamsaat.com:212.175.40.11:86400
.ozcanlarticaret.com:139.179.139.251:a:259200
.ozcanlarticaret.com:212.175.40.11:b:259200
@ozcanlarticaret.com:212.175.40.36:a::86400
+www.ozcanlarticaret.com:212.175.40.36:86400
+mail.ozcanlarticaret.com:212.175.40.36:86400
.barutrock.com:139.179.139.251:a:259200
.barutrock.com:212.175.40.11:b:259200
@barutrock.com:212.175.40.36:a::86400
+www.barutrock.com:212.175.40.36:86400
+mail.barutrock.com:212.175.40.36:86400
=node4.core.gen.tr:212.175.40.56:86400
.dokay.info.tr:139.179.139.251:a:259200
.dokay.info.tr:212.175.40.11:b:259200
@dokay.info.tr:212.175.40.55:a::86400
+mail.dokay.info.tr:212.175.40.11:86400
+www.dokay.info.tr:139.179.139.251:86400
+www-tr.dokay.info.tr:139.179.139.251:86400
+www-en.dokay.info.tr:139.179.139.251:86400
.hasankazdagli.com:139.179.139.251:a:259200
.hasankazdagli.com:212.175.40.11:b:259200
@hasankazdagli.com:212.175.40.55:a::86400
+www.hasankazdagli.com:212.175.40.11:86400
+mail.hasankazdagli.com:212.175.40.11:86400
.par.com.tr:139.179.139.251:a:259200
.par.com.tr:212.175.40.11:b:259200
@par.com.tr:89.106.12.72:a::86400
+www.par.com.tr:89.106.12.109:86400
+mail.par.com.tr:89.106.12.72:86400
.itir.net:139.179.139.251:a:259200
.itir.net:212.175.40.11:b:259200
@itir.net:212.175.40.11:a::86400
+www.itir.net:212.175.40.11:86400
+mail.itir.net:212.175.40.11:86400
+webmail.core.gen.tr:212.175.40.12:86400
.toppareresearch.com:139.179.139.251:a:259200
.toppareresearch.com:212.175.40.11:b:259200
@toppareresearch.com:212.175.40.11:a::86400
+www.toppareresearch.com:139.179.139.251:86400
+mail.toppareresearch.com:212.175.40.11:86400
.turkiyelizbongundemi.org:139.179.139.251:a:259200
.turkiyelizbongundemi.org:212.175.40.11:b:259200
@turkiyelizbongundemi.org:212.175.40.11:a::86400
+www.turkiyelizbongundemi.org:212.175.40.11:86400
+www-en.turkiyelizbongundemi.org:212.175.40.11:86400
+www-tr.turkiyelizbongundemi.org:212.175.40.11:86400
+mail.turkiyelizbongundemi.org:212.175.40.11:86400
.meditate-eu.org:139.179.139.251:a:259200
.meditate-eu.org:212.175.40.11:b:259200
@meditate-eu.org:212.175.40.11:a::86400
+www.meditate-eu.org:139.179.139.251:86400
+mail.meditate-eu.org:212.175.40.11:86400
.turital.com:139.179.139.251:a:259200
.turital.com:212.175.40.11:b:259200
@turital.com:89.106.12.82:a::86400
+www.turital.com:139.179.139.251:86400
+mail.turital.com:89.106.12.82:86400
.italygas.com:139.179.139.251:a:259200
.italygas.com:212.175.40.11:b:259200
@italygas.com:84.51.26.206:a::86400
+www.italygas.com:139.179.139.25:86400
+mail.italygas.com:84.51.26.206:86400
")

(defparameter *name-server* (make-instance 'name-server))
(describe *name-server*)
(start *name-server*)
(status *name-server*)
(stop *name-server*)

(find-domain-records *name-server* "core.gen.tr")
(name-server.refresh *name-server*)

(add-ns *name-server* "ns1.core.gen.tr" "1.2.3.4")
(add-mx *name-server* "mx.core.gen.tr" "1.2.3.5")

