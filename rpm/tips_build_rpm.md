# RPM
https://stackoverflow.com/questions/880227/what-is-the-minimum-i-have-to-do-to-create-an-rpm-file
rpmbuild --define "_topdir `pwd`" -ba SPECS/chaten.spec
sudo rpm -ivh  --replacepkgs chaten-1.0-1.x86_64.rpm  --nodeps