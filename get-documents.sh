#!/bin/bash
#This Document Download AWS Predefined Documents Command/Automation/Session/Policy with YAML Format with naming convention DocumentName_Version
#The Downloaded Document YAML Format Maybe Broken Because Of paterns within the documents itself
#v2 reduce api calls
mkdir -p Data && cd Data
for DocumentType in $(aws ssm list-documents --no-cli-pager --filter Key=Owner,Values=Amazon --query DocumentIdentifiers[].DocumentType --output text |tr '\t' '\n'|sort|uniq)
	do
		echo -e  "######\nAll $DocumentType start Downloading"
		mkdir -p $DocumentType 
		for DocumentVersion in  $(aws ssm list-documents --no-cli-pager --query 'DocumentIdentifiers[].{name:Name,version:DocumentVersion}'  --filter Key=DocumentType,Values=$DocumentType Key=Owner,Values=Amazon --output text|sed 's/\t/_/g'|sed 's/$/.yaml/g'|tee ${DocumentType}/${DocumentType}_DocumentsVersionsList.txt|egrep -v `ls $DocumentType -1 |tr '\n' '|' |sed 's/.$//'`)
				do
					DocumentName=`echo $DocumentVersion |cut -d'_' -f1`
					aws ssm get-document   --no-cli-pager  --query Content --document-format YAML --output yaml --name $DocumentName  | sed 's/\\n/\n/g'|sed 's/\\//g'|tail -n +2|head -n -1 > $DocumentType/$DocumentVersion && echo -e "\t\t$DocumentName Downloaded with Last version "
				done
		echo -e "All $DocumentType Downloaded\n######"
	done
