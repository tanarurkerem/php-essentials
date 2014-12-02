#!/bin/bash

# Set of basic tests to ensure minimum hygene.

set -e
set -u
# set -x

# Preparing for nice and colourful output
export TERM=xterm-256color
CRED=$(tput setaf 160)
CGRN=$(tput setaf 28)
CRES=$(tput sgr0)

function run()
{
	docker run --rm -i -t \
		--volume ${PWD}/test:/test:r \
		--workdir /test \
		tanarurkerem/php-essentials $@
}

function report()
{
	if [ "$1" -eq 0 ]; then
		echo -n "${CGRN} ✓ "
	else
		echo -n "${CRED} ✘ "
	fi;

	echo "${2}${CRES}"
}

# Basic CLI PHP
run php -f hello.php |grep 'Hello world' >>debug.log 2>&1
report $? "php"


# Server
CID=$(docker run -d --publish 64001:64001 \
	--volume ${PWD}/test:/test:r \
	--workdir /test \
	tanarurkerem/php-essentials php -S 0.0.0.0:64001);
report $? "php server started"

wget -q -O - http://$(boot2docker ip):64001/hello.php|grep 'Hello world' >>debug.log 2>&1
 report $? "php server responded"

(docker stop $CID && docker rm $CID) >>debug.log 2>&1
 report $? "php server stoped & removed"


# Tools:
run composer|grep '\[options\] command \[arguments\]' >>debug.log 2>&1
report $? "composer"

run pear version|grep "PEAR Version" >>debug.log 2>&1
report $? "pear"

run phpunit --version|head -n1|grep "Bergman" >>debug.log 2>&1
report $? "phpunit"

run phpcpd --version|head -n1|grep "Bergman" >>debug.log 2>&1
report $? "phpcpd"

run phpdcd --version|head -n1|grep "Bergman" >>debug.log 2>&1
report $? "phpdcd"

run pdepend --version|head -n1|grep "Pichler" >>debug.log 2>&1
report $? "pdepend"

run phpmd --version|head -n1|grep "Pichler" >>debug.log 2>&1
report $? "phpmd"

run phpcs --version|head -n1|grep "Squiz" >>debug.log 2>&1
report $? "phpcs"

run behat --version|head -n1|grep "Behat" >>debug.log 2>&1
report $? "behat"

rm debug.log
