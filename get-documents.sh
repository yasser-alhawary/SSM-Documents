#!/bin/bash
#This Document Download AWS Predefined Documents Command/Automation/Session/Policy with YAML/JSON Format with naming convention DocumentName_Version
#v3 add json/yaml as postional parameter option default is yaml
mkdir -p Data 
DocumentFormat=`[  "$@" = "json" ] 2> /dev/null && echo -n json || echo -n yaml`
for DocumentType in $(aws ssm list-documents --no-cli-pager --filter Key=Owner,Values=Amazon --query DocumentIdentifiers[].DocumentType --output text |tr '\t' '\n'|sort|uniq)
	do
		echo -e  "######\nAll \033[1;32m $DocumentType \033[0m start Downloading"
		mkdir -p Data/${DocumentType} 
		touch Data/${DocumentType}/${DocumentType}_List.txt && ! [ -s Data/${DocumentType}/${DocumentType}_List.txt ] && date "+%F-%H-%M-%S" > Data/${DocumentType}/${DocumentType}_List.txt
		for DocumentVersion in  $(aws ssm list-documents --no-cli-pager --query 'DocumentIdentifiers[].{name:Name,version:DocumentVersion}'  --filter Key=DocumentType,Values=${DocumentType} Key=Owner,Values=Amazon --output text|sed 's/\t/_/g'|sed "s/\$/.${DocumentFormat}/g"|egrep -v `cat Data/${DocumentType}/${DocumentType}_List.txt |tr '\n' '|' |sed 's/.$//'`)
				do
					DocumentName=`echo $DocumentVersion |rev | cut -d'_' -f 2- | rev`
					mkdir -p Data/${DocumentType}/${DocumentName}
					aws ssm get-document   --no-cli-pager   --document-format `echo ${DocumentFormat} | tr '[:lower:]' '[:upper:]'` --output text --name $DocumentName  > Data/${DocumentType}/${DocumentName}/${DocumentName}.${DocumentFormat} && echo -e "\t\t\033[1;32m $DocumentName \033[0m Downloaded with Last version " && echo $DocumentVersion >> Data/${DocumentType}/${DocumentType}_List.txt
				done
		echo -e "All \033[1;32m $DocumentType \033[0m Downloaded\n######"
	done
