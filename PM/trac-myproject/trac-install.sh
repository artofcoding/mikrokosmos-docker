#!/bin/sh
#
# Copyright (C) 2018-2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

PROJECT=MyProject

TRAC_ADMINUSER="admin"
TRAC_DATA="/var/trac"
PROJECT_DIR="${TRAC_DATA}/${PROJECT}"
export PROJECT_DIR
DBLINK="postgres://trac:trac@trac-db:5432/trac?schema=trac"
export DBLINK

function trac_install_plugin_from_source() {
    local name=$1 ; shift
    local url=$1 ; shift
    local setuppy_dir=$1 ; shift
    local download="${TRAC_DATA}/${name}.zip"
    local location="${TRAC_DATA}/${name}"
    curl -L \
        -o "${download}" \
        "${url}" \
    && mkdir "${location}" \
    && unzip -d "${location}" "${download}"
    if [ -d "${location}" ]
    then
        cd "${location}"
        [ -z "${setuppy_dir}" ] && setuppy_dir="$(dirname $(find "${location}" -type f -name setup.py))"
        cd ${setuppy_dir}
        python setup.py bdist_egg \
        && python setup.py install
    fi
}

function trac_upgrade_all() {
    trac-admin "${PROJECT_DIR}" upgrade --no-backup
    trac-admin "${PROJECT_DIR}" wiki upgrade
}

if [ ! -d "${PROJECT_DIR}" ]
then
    trac-admin "${PROJECT_DIR}" initenv "${PROJECT}" "${DBLINK}"
fi

if [ ! -f "${TRAC_DATA}/trac-digest.py" ]
then
    curl -L \
        -o "${TRAC_DATA}/trac-digest.py" \
        http://www.agilofortrac.com/en/download/trac-digest.py
fi

if [ ! -f "${PROJECT_DIR}/users.digest" ]
then
    #PW=$(secpwgen -Aad 12)
    PW=$(pwgen 12 1)
    python ${TRAC_DATA}/trac-digest.py \
        -u "${TRAC_ADMINUSER}" \
        -p "${PW}" \
        >>"${PROJECT_DIR}/users.digest"
    echo ""
    echo "* ---------------------------------"
    echo "* Password is:  ${PW}"
    echo "* ---------------------------------"
    echo ""
    trac-admin "${PROJECT_DIR}" permission add "${TRAC_ADMINUSER}" TRAC_ADMIN
fi

echo ""
echo "*"
echo "* TracIniAdminPlugin"
echo "*"
echo ""
easy_install-2.7 https://trac-hacks.org/svn/iniadminplugin/0.11
trac-admin "${PROJECT_DIR}" config set components iniadmin.* enabled
echo "* done"

echo ""
echo "*"
echo "* TracXmlRpcPlugin"
echo "*"
echo ""
pip install TracXMLRPC
trac-admin "${PROJECT_DIR}" config set components tracrpc.* enabled
trac-admin "${PROJECT_DIR}" permission add "${TRAC_ADMINUSER}" XML_RPC
echo "* done"

echo ""
echo "*"
echo "* TracSubTicketsPlugin"
echo "*"
echo ""
pip install TracSubTickets
trac-admin "${PROJECT_DIR}" config set components tracsubtickets.* enabled
echo "* done"

echo ""
echo "*"
echo "* TracTicketRelationPlugin"
echo "*"
echo ""
trac_install_plugin_from_source \
    TracScheduleAndRelationPlugin \
    https://github.com/CaulyKan/TracTicketRelationPlugin/archive/master.zip
trac_upgrade_all
trac-admin "${PROJECT_DIR}" config set components ticketrelation.* enabled
cat >>${PROJECT_DIR}/conf/trac.ini <<EOF

[ticket-custom]
activity_finish_date = time
activity_finish_date.label = Planned Finish
activity_finished_date = time
activity_finished_date.label = Actual Finish
activity_start_date = time
activity_start_date.label = Planned Start
activity_started_date = time
activity_started_date.label = Actual Start
bug_task_relation_a = textarea
bug_task_relation_a.format = summary,status,owner
bug_task_relation_a.label = All Tasks
bug_task_relation_a.relation_type = many
bug_task_relation_b = text
bug_task_relation_b.label = Related Defect
bug_task_relation_b.relation_type = one

[ticket-relation]
bug_task_relation = defect -> task
bug_task_relation.label = Related Defect -> All Tasks
bug_task_relation.type = one -> many

[ticket-relation-schedule]
task.show_schedule = True
EOF
echo "* done"

echo ""
echo "*"
echo "* TracTicketTemplatePlugin"
echo "*"
echo ""
trac_install_plugin_from_source \
    TracTicketTemplatePlugin \
    'https://trac-hacks.org/browser/tractickettemplateplugin?rev=17653&format=zip' \
    tractickettemplateplugin/1.0
trac_upgrade_all
trac-admin "${PROJECT_DIR}" config set components tickettemplate.* enabled
echo "* done"

echo ""
echo "*"
echo "* TracWorkflowAdminPlugin"
echo "*"
echo ""
pip install 'https://trac-hacks.org/browser/tracworkflowadminplugin/0.12/?rev=latest&format=zip'
trac_upgrade_all
trac-admin "${PROJECT_DIR}" config set components tracworkflowadmin.web_ui.* enabled
echo "* done"

echo ""
echo "*"
echo "* TracCardsPlugin"
echo "*"
echo ""
#easy_install-2.7 https://trac-hacks.org/svn/cardsplugin/trunk
pip install https://trac-hacks.org/svn/cardsplugin/trunk
trac-admin "${PROJECT_DIR}" config set components cards.* enabled
echo "* done"

echo ""
echo "*"
echo "* TracWatchlistPlugin"
echo "*"
echo ""
pip install TracWatchlistPlugin
trac_upgrade_all
trac-admin "${PROJECT_DIR}" config set components tracwatchlist.* enabled
trac_upgrade_all
echo "* done"

echo ""
echo "*"
echo "* TracUserPicturesPlugin"
echo "*"
echo ""
pip install trac-UserPicturesPlugin
trac-admin "${PROJECT_DIR}" config set components userpictures.* enabled
trac-admin "${PROJECT_DIR}" config set tickettemplate field_list "summary, description, reporter, owner, priority, cc, milestone, component, version, type"
trac-admin "${PROJECT_DIR}" config set tickettemplate enable_custom true
echo "* done"

echo ""
echo "*"
echo "* BlueFlatTheme"
echo "*"
echo ""
trac_install_plugin_from_source \
    BlueFlatTheme \
    'https://trac-hacks.org/browser/blueflattheme?rev=17657&format=zip'
trac-admin "${PROJECT_DIR}" config set components themeengine.* enabled
trac-admin "${PROJECT_DIR}" config set components blueflattheme.* enabled
trac-admin "${PROJECT_DIR}" config set theme theme blueflat
#trac-admin "${PROJECT_DIR}" config set blue-flat-theme replace_jquery 0
echo "* done"

exit 0
