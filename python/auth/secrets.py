'''
  This class lets us keep the user ids and passwords outside of the git repo.
  This is basically a port of the equivalent I added to Bruno's old stats code.
  Owain Kenway
'''
class Secrets:
    def __init__(self):
        import configparser
        import os.path

        self.filename = os.path.join(os.path.expanduser("~"), ".stats_secrets", "accounts")

        secretconfig = configparser.ConfigParser()
        secretconfig.read(self.filename)

        self.dbuser = secretconfig.get("database", "user").strip("'")
        self.dbpasswd = secretconfig.get("database", "pass").strip("")

        # See if we have an AD password available to us anywhere:
        self.ad = False
        self.adsource = 0

        # First check our config file for "ad" or "ldap" sections.
        if secretconfig.has_section("ad"):
            self.aduser = secretconfig.get("ad", "user").strip("'")
            self.adpasswd = secretconfig.get("ad", "pass").strip("")
            self.ad = True
            self.adsource = 1
        
        elif secretconfig.has_section("ldap"):
            self.aduser = secretconfig.get("ldap", "user").strip("'")
            self.adpasswd = secretconfig.get("ldap", "pass").strip("")
            self.ad = True
            self.adsource = 2
        
        # Then check to see if we have a ~/.adpw as for the ClusterStats repo.
        elif os.path.exists(os.path.expanduser("~/.adpw")):
            self.aduser = "AD\sa-ritsldap01"
            
            with open(os.path.expanduser("~/.adpw")) as f:
                self.passwd = f.read().strip()
            self.ad = True
            self.adsource = 3

        # Then check to see if we have a system-wide password.
        elif os.path.exists("/shared/ucl/etc/adpw"):
            self.aduser = "AD\sa-ritsldap01"
            
            with open("/shared/ucl/etc/adpw") as f:
                self.passwd= f.read().strip()
            self.ad = True
            self.adsource = 4



        