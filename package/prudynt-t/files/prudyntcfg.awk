#!/usr/bin/awk -f

function w(l) {
	if(_fl){print l>>ARGV[1]}else{print l>ARGV[1]}
}

function e(l,d) {
	if(d==1) {
		_v=substr(l,index(l,":")+1);
	} else {
		_v=substr(l,0,index(l,":")-1);
	}
	gsub(/^[;|[:space:]]*|[;|[:space:]]*$/,"",_v);
	return _v;
}

function p(l) {
	if(length(l)&&!match(l,"^[[:space:]]*#")&&!match(l,"^\s*$")){
		while(length(l)){
			if(!t){
				if(match(l,"[[:space:]]*(.*):")){
					_s=e(substr(l,RSTART, RLENGTH),0);
					t=1;
					l=substr(l,RSTART+RLENGTH);
				}else {
					l="";
				}
			} else if(t==1){
				if(match(l,"{")){
					t=2;
					l=substr(l,RSTART+1);
				}else{
					l="";
				}
			}else if(t==2){
				if(match(l,"}")){
					if(s==_s&&f~"^set$"){
						_il="\011"e": "v";";
						if(_m) {
							if(length(v)){
								c[_m]=_il;
							}else{
								gsub(/^[[:space:]]*#[[:space:]]*/,"\011",c[_m]);
							}
						}else{
							c[_n++]=_il;
						}
					}
					t=0;
					x=RSTART;
					p(substr(l,0,x-1));
					l=substr(l,x+1);
				}else{
					if(s==_s&&l~"^[[:space:]]*"e"[[:space:]]*:.*;"){
						_m=_n;
						if(f~"^get$"){
							print e(l,1);
						}else if(f~"^unset$"){
							gsub(/^[[:space:]]*/,"\011# ",$0)
						}
					} else if(f~"^list$"){
						if(length(s)){
							if(s==_s){
								print _s"__"e(l,0)"="e(l,1);
							}
						}else{
							print _s"__"e(l,0)"="e(l,1);
						}
					}
					if(match(l,/;[^;]*$/)){
						l=substr(l,RSTART+1);
					}else{
						l="";
					}
				}
			}
		}
	} else {
		if(s==_s&&l~"^[[:space:]|#]*"e"[[:space:]]*:"){
			_m=_n;
		}
	}
}

BEGIN {
	f=ARGV[1];
	s=ARGV[2];
	e=ARGV[3];
	v=ARGV[4];
	if(!ARGV[1]){
		print "prudynt configuration helper v0.1";
		print "";
		print "Usage [get|set|list|unset] <section> <setting> <value>";
		print "";
		print "		get		receive a value for <section> <setting>";
		print "		set		set <value> for <section> <setting>";
		print "					 if value is not provided but setting exists as comment, it will be uncomment";
		print "		list	 list all configured <settings>. Can be limited by providing a <section>";
		print "		unset	comment a <setting> if exists";
		exit;
	}
	for (i=ARGC;i>2;i--){ARGC--}
	ARGV[1]="/etc/prudynt.cfg";
}
{p($0);c[_n++]=$0}
END{
	if(f~"^set$|^unset$") {
		x=length(c);
		for(i=0;i<_n;i++) {
			w(c[i]);
		}
	}
}
