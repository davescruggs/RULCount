public with sharing class CustomAppInventoryUtility {
    // configuration data
    List<String> licenseLabels = new List<String>{'Salesforce Platform'};

    // constructor
    public CustomAppInventoryUtility() {}

    public Map<Id, UserLicense> getPlatformLicenses(){
        Map <Id, UserLicense> platformLicenses = new Map<Id, UserLicense>([SELECT Id, Name FROM UserLicense WHERE MasterLabel in :licenseLabels]);
        return platformLicenses;
    }

    public Map<Id, Profile> retrievePlatformProfiles(){
        Map <Id, UserLicense> platformLicenses = getPlatformLicenses();
        system.debug('>>> licenses: ' + platformLicenses);
        Set<Id> licenseIds = platformLicenses.keySet();
        Map <Id, Profile> profiles = 
            new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE UserLicenseId IN :licenseIds]);
        system.debug('>>> profiles: ' + profiles);
        return profiles;
    }
    public Map<String, Integer> retrievePopulatedPlatformProfiles(){
        Map <Id, Profile> profiles = retrievePlatformProfiles();
        Set<Id> profileSet = profiles.keySet();
        Map<String, Integer> profileMap = new Map<String, Integer>();
        for(AggregateResult aggRes: [
            SELECT Count(Id) UserCount, ProfileId FROM User 
            WHERE ProfileId IN :profileSet
            GROUP BY ProfileId
        ]){
            String profileName = profiles.get((Id) aggRes.get('ProfileId')).Name;
            Integer userCount = (Integer) aggRes.get('UserCount');
            profileMap.put(profileName, userCount);
            System.Debug('>>> profileName: ' + profileName + '  >>> count: ' + userCount);
        }
        return profileMap;
    }
    public void countApps(){
        List <AppDefinition> a = new List <AppDefinition>(); 
        Map <Id, UserLicense> platformLicenses = getPlatformLicenses();
        system.debug('>>> licenses: ' + platformLicenses);
        Set<Id> licenseIds = platformLicenses.keySet();
        
        List <Profile> profiles = [SELECT Id, Name FROM Profile where UserLicenseId in :licenseIds];
        system.debug('>>> profiles: ' + profiles);
        List <User> u = new List <User>(); 
        List <ID> sRecordIDs = new List <ID>(); 
        Map <String, List<String>> appInventory = new Map<String, List<String>>();
        a = [select id from AppDefinition]; system.debug('>>> # of apps: '+a.size()); 
        u = [select id from User where ProfileId in :profiles and IsActive = TRUE]; 
        system.debug('>>> # of users: '+u.size()); 
        for(User uid : u){
        for(AppDefinition c : a) 
            { 
                    UserRecordAccess i =null; i = [SELECT RecordID FROM UserRecordAccess 
                                                    WHERE UserId = :uid.id 
                                                    AND RecordID= :c.id AND HasReadAccess = True]; 
                    sRecordIDs.add(i.id); 
            } 
        }
        system.debug('>>>'+ sRecordIDs.size()); 
        system.debug('>>>'+ sRecordIDs); 
    }
}
