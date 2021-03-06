create user oracle identified by oracle;
grant dba to oracle;

CREATE USER "DOTCMS_SENDER" PROFILE "DEFAULT" IDENTIFIED BY "XXXXXXXX" ACCOUNT UNLOCK;

GRANT "CONNECT" TO "DOTCMS_SENDER";
GRANT "EXP_FULL_DATABASE" TO "DOTCMS_SENDER";
GRANT "GATHER_SYSTEM_STATISTICS" TO "DOTCMS_SENDER";
GRANT "IMP_FULL_DATABASE" TO "DOTCMS_SENDER";
-- GRANT "MGMT_USER" TO "DOTCMS_SENDER";
GRANT "OEM_ADVISOR" TO "DOTCMS_SENDER";
GRANT "OEM_MONITOR" TO "DOTCMS_SENDER";
-- GRANT "OLAP_USER" TO "DOTCMS_SENDER";
GRANT "RESOURCE" TO "DOTCMS_SENDER";

ALTER USER "DOTCMS_SENDER" DEFAULT ROLE ALL;
EXIT