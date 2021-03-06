# Changelog

## 0.1.8
* Better key lookup on hashes.
* Changed #camelize to work the same way as in Rails.

## 0.1.5
* #camelize in parameters and complex types is only called if they are declared as symbols.
  This allows usage of custom character casing when writing the SOAP services.
* Parameters are now camelized with first letter as lowercase.

## 0.1.4
* Parameters are now read in the correct order, as specified in the metadata;
* Complex return types are now working correctly;
* DRYed some code;
* Added more logs.

## 0.1.3
* More fixes for .NET interoperability.

## 0.1.2
* Fixed a bug when returning SOAP:Faults.

## 0.1.1
* Added support for SOAP 1.2 Faults;
* Refactored the request handling into its own class.

## 0.1.0
* Added specs and fixed basic support for SOAP:Fault.

## 0.0.6
* Added basic support for SOAP:Fault.

## 0.0.5
* Removed the dual-namespace option. Now there's only one.
* Generating WSDL for SOAP 1.2;
* Added an option on the DSL to change the service name;
* Changed some conventions on the generated WSDL so Visual Studio .NET can understand it better.

## 0.0.4
* Fixed the samples;
* Fixed some bugs that prevented the generated WSDL to be used with Visual Studio.

## 0.0.3
* Added support for WSDL documentation;
* Added wasabi and WebMock to the specs;
* Added support for complex types on parameters, in addition to return values;
* Request handling for very simple cases.

## 0.0.2
* WSDL generation code extracted to its own module;
* Added support for complex return types;
* Fixed a bug on the String#camelize extension;
* DateTime support on parameters and return values.

## 0.0.1
* Initial, experimental version
