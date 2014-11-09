#!/bin/bash
STARTDIR=$(pwd)
VERSION=0.8.12
DESTINATION_HELP='-d Chicago Boss destination path'
VERSION_HELP='-v sets the Chicago Boss Project version'
OVERWRITE_HELP='-u will overwrite if ChicagoBoss exists and install in default dir ChicagoBoss (skips versioning, aka upgrade)'

function install()
{
  if [ -z "$COMPILERDIR" ]
then
  echo "Enter the Chicago Boss Dir (if no dir is selected we will download ChicagoBoss into $HOME/ChicagoBoss-${VERSION})"
  read COMPILERDIR
fi


if [[ 1 > ${#COMPILERDIR} ]]
then
CBBDIR=${HOME}
else
CBBDIR=${COMPILERDIR}
fi

## fetch and install chicagoboss
cd ${CBBDIR}
wget https://github.com/ChicagoBoss/ChicagoBoss/archive/v"${VERSION}".tar.gz
tar -xvzf v"${VERSION}".tar.gz

if [ -z "$OVERWRITE" ]
then
cd ChicagoBoss-"${VERSION}"
else
rm -drf ChicagoBoss
mv ChicagoBoss-"${VERSION}" ChicagoBoss
cd ChicagoBoss
fi

COMPILERDIR=$(pwd)

echo "...Building Chicago Boss..."
make
cd ${STARTDIR}
#sed s_{path, \".*/ChicagoBoss.[[:digit:]]*.[[:digit:]]*.[[:digit:]]*_{path, \"${COMPILERDIR}_ rebar.config > rebar.config # may be needed in some cases
./rebar get-deps compile

if [ -z "$GIT" ]
then
echo "Create a new git project (Y/N)"
read GIT
fi

if [ -n "$GIT" ]
then
git init
echo "Enter the project Name"
read PROJNAME
echo "Enter a short one line description of the project"
read PROJDESC
echo "# $PROJNAME" > Readme.md
echo "## $PROJDESC" >> Readme.md
git add .
git commit -m "initial commit"
fi

}

function help()
{
    echo ""
    echo "Chicago Boss Installer by Jason Clark <mithereal@gmail.com>"
    echo ""
    echo "Usage: install $DESTINATION_HELP "
    echo $VERSION_HELP
}

# newbitbucketrepo - creates remote bitbucket repo and adds it as git remote to cwd
function newbitbucketrepo {
    echo 'Bitbucket Username:'
    read username
    echo 'Bitbucket Password:'
    read password
    echo 'Repo name:'
    read reponame

    curl --user $username:$password https://api.bitbucket.org/1.0/repositories/ --data name=$reponame --data is_private='true'
    git remote add origin git@bitbucket.org:$username/$reponame.git
    git push -u origin --all
    git push -u origin --tags
}


while getopts ":d:?:v" opt; do
    case $opt in
        d)
            COMPILERDIR=$OPTARG
            ;;
        v)
            VERSION=$OPTARG
            ;;
        u)
            OVERWRITE=$OPTARG
            ;;
        ?)
            help
exit 0
            ;;
    esac
done

install
