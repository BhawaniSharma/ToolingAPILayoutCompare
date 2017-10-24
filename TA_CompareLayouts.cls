/**
 * 	Purpose			:	This class is created to do a POC for Tooling APIs strength. For now, this class is having method to retrieve the
 							page layout schema from Source and Target org and then display it on UI with differences.
 * 
 * 	Created By		:
 * 
 * 	Created Date	:	09/05/2017
 * 
 * 	Revision Logs	:	V_1.0 - Created
 * 
 **/
global with sharing class TA_CompareLayouts {
    
    //Properties
    public static Set<String> sourceFields {get; set;}
    public static List<PageLayourWrapper> propertiesSource {get; set;} 
    public static List<PageLayourWrapper> propertiesTarget {get; set;} 
    public static List<PageLayoutCompWrapper> compareResults {get; set;}
    
    //This method is being used to retrive the page layout schema from source org.
    //TODO: Refactoring based on org type
    @RemoteAction
    global static List<PageLayourWrapper> querySourceData(String objectName) {
        
        propertiesSource = processLayout(UserInfo.getSessionID(), 'Account Layout', true);
        return propertiesSource;
    }
    
    //This method is being used to retrive the page layout schema from target org.
    //TODO: Refactoring based on org type
    @RemoteAction
    global static List<PageLayourWrapper> queryTargetData(String objectName) {
        
        
        String targetSessionId = getTargetSessionId();
        propertiesTarget = processLayout(targetSessionId, 'Account Layout', false);
        
        return propertiesTarget;
    }
    
    //This method compares both the layouts and respond to page with the complete wrappeer with resultant data
    //TODO: Refactoring
    @RemoteAction
    global static List<PageLayoutCompWrapper> compareLayouts(String objectName) {
    	
    	compareResults = new List<PageLayoutCompWrapper>();
    	sourceFields = new Set<String>();
    	
    	propertiesSource = processLayout(UserInfo.getSessionID(), 'Account Layout', true);
    	String targetSessionId = getTargetSessionId();
        propertiesTarget = processLayout(targetSessionId, 'Account Layout', false);
        
    	for(PageLayourWrapper pT : propertiesTarget) {
    		
    		PageLayoutCompWrapper result = new PageLayoutCompWrapper();
    		if(sourceFields.contains(pT.fieldName)) {
    			
    			result.fieldName = pT.fieldName;
    			result.inSource = true;
    			result.inTarget = true;
    		} else {
    			
    			result.fieldName = pT.fieldName;
    			result.inSource = false;
    			result.inTarget = true;
    			result.bgcolor = 'red';
    		}
    		compareResults.add(result);
    	}
    	return compareResults;
    }
    
    //This method process the Page Layout schema and prepare the wrapper list with that.
    private static List<PageLayourWrapper> processLayout(String sessionId, String layoutId, Boolean isSource) {
        
        List<PageLayourWrapper> properties = new List<PageLayourWrapper>();
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
                
        req.setEndpoint('https://na73.salesforce.com/services/data/v40.0/tooling/query/?q=Select+Id,Name,EntityDefinitionId,FullName,LayoutType,ManageableState,Metadata,NamespacePrefix,ShowSubmitAndAttachButton,TableEnumOrId+from+Layout+where+Name+=+\'Account%20Layout\'');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String body = res.getBody();
        Map<String, Object> mapLayoutProperties = (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> listLayoutRecords = (List<Object>)mapLayoutProperties.get('records');
        for(Object layout : listLayoutRecords) {
                
            Map<String, Object> mapRecordProperties = (Map<String, Object>)layout;
            Map<String, Object> mapMatadataProperties = (Map<String, Object>)mapRecordProperties.get('Metadata');
            List<Object> listLayoutSections = (List<Object>)mapMatadataProperties.get('layoutSections');

            for(Object layoutSection : listLayoutSections) {
                    
                Map<String, Object> mapLayoutSection = (Map<String, Object>)layoutSection;
                List<Object> listLayoutColumns = (List<Object>)mapLayoutSection.get('layoutColumns');
                for(Object layoutColumn : listLayoutColumns) {
                    
                    Map<String, Object> mapLayoutColumnProperties = (Map<String, Object>)layoutColumn;
                    List<Object> listLayoutItems = (List<Object>)mapLayoutColumnProperties.get('layoutItems');
                    
                    for(Object layoutItem : listLayoutItems) {
                        
                        Map<String, Object> mapLayoutItem = (Map<String, Object>)layoutItem;
                        System.debug(mapLayoutSection.get('label') + ' - ' + mapLayoutItem.get('field'));
                        
                        PageLayourWrapper pWrapper = new PageLayourWrapper();
                        pWrapper.sectionName = String.valueOf(mapLayoutSection.get('label'));
                        pWrapper.fieldName = String.valueOf(mapLayoutItem.get('field'));
                        if(isSource)
                        	sourceFields.add(pWrapper.fieldName);
                        properties.add(pWrapper);
                    }
                }
            }
        }
        return properties;
    }
    
    private static String getTargetSessionId() {
        
        String loginEnvelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
                                + '  xmlns:urn="urn:partner.soap.sforce.com">'
                                + '  <soapenv:Body>'
                                + '    <urn:login>'
                                + '      <urn:username>session2@dreamforce.demo</urn:username>'
                                + '      <urn:password>dreamforce.demo5</urn:password>'
                                + '    </urn:login>'
                                + '  </soapenv:Body>'
                                + '</soapenv:Envelope>';
                                
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '""');
                
        req.setEndpoint('https://login.salesforce.com/services/Soap/u/10.0');
        req.setBody(loginEnvelope);
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String sessionId = res.getbody().subStringBetween('<sessionId>', '</sessionId>').trim();
        return sessionId;
    }
    
    //Inner class for some temporary purpose
    global class PageLayourWrapper {
        
        public String sectionName {get; set;}
        public String fieldName {get; set;}
        public String bgcolor {get; set;}
    }
    
    //Inner class for comparison purpose
    global class PageLayoutCompWrapper {
        
        public String sectionName {get; set;}
        public String fieldName {get; set;}
        public Boolean inSource {get; set;}
        public Boolean inTarget {get; set;}
        public String bgcolor {get; set;}
    }   
}