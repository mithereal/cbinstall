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
CBBDIR=${STARTDIR}
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
make edoc
cd ${STARTDIR}

if [ -f "rebar.config" ]
then
#sed s_{path, \".*/ChicagoBoss.[[:digit:]]*.[[:digit:]]*.[[:digit:]]*_{path, \"${COMPILERDIR}_ rebar.config > rebar.config # may be needed in some cases
./rebar get-deps compile
else
cd ${COMPILERDIR}
echo "Enter the project Name"
read PROJNAME
make app PROJECT=${PROJNAME}
cd ../${PROJNAME}

if [ -z "$GIT" && ! -d "${STARTDIR}/.git"]
then
echo "Create a new git project (Y/N)"
read GIT
fi

if [ ${GIT} != "n" && ${GIT} != "N"]
then
git init
echo "Enter a short one line description of the project"
read PROJDESC
AUTHOR = git config user.name
echo "# ${PROJNAME}" > README.md
echo "Credits" >> README.md
echo "-------" >> README.md
echo "###### Author: ${AUTHOR}" >> README.md
echo "${PROJDESC}" >> README.md
git add .
git commit -m "initial commit"

if [ -z "$SYNC" ]
then
echo "Sync with Bitbucket (Y/N)"
read SYNC
fi

if [ ${SYNC} != "n" && ${SYNC} != "N"]
then
newbitbucketrepo()
fi

fi

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
function newbitbucketrepo() {
    echo 'Bitbucket Username:'
    read username
    echo 'Bitbucket Password:'
    read password
    echo "Repo name: (ex. ${PROJNAME} )"
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
