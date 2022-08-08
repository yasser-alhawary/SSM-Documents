#!/bin/bash
#This Document Download AWS Predefined Documents Command/Automation/Session/Policy with YAML Format with naming convention DocumentName_Version
#The Downloaded Document YAML Format Maybe Broken Because Of paterns within the documents itself
for DocumentType in Command Automation Policy Session
	do
		echo "All $DocumentType start Downloading"
		for DocumentName in  `aws ssm list-documents --no-cli-pager --query 'DocumentIdentifiers[].Name'  --filter Key=DocumentType,Values=$DocumentType	Key=Owner,Values=Amazon --output text`
				do
					LastVersion=$(aws ssm describe-document --name  $DocumentName  --query Document.DocumentVersion --output text)
					DocumentFile=$DocumentType/${DocumentName}_${LastVersion}.yaml
					if [ -e $DocumentFile ]
						then
							echo " Last Version of $DocumentName is already exist"
						else
							aws ssm get-document   --no-cli-pager  --query Content --document-format YAML --output yaml --name $DocumentName  | sed 's/\\n/\n/g'|sed 's/\\//g'|tail -n +2|head -n -1 > $DocumentFile && echo " $DocumentName Downloaded with version $LastVersion "
					fi
					
				done
		echo "All $DocumentType Downloaded"
	done
