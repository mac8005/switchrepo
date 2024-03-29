function switch-repo(){
    if ! [ -z $1 ] ; then
        if  [ ! -n "${SWITCHREPO_WORKROOT}" ]; then
          echo '$SWITCHREPO_WORKROOT missing. Please set Directory for Repos e.g. export SWITCHREPO_WORKROOT=/Users/massimo/repos'
          return
        fi
        if  [ ! -n "${SWITCHREPO_ORG}" ]; then
          echo '$SWITCHREPO_ORG missing. Please set Azure DevOps Org for Repos e.g. export SWITCHREPO_ORG=myorg'
          return
        fi
        if  [ ! -n "${SWITCHREPO_PROJ}" ]; then
          echo '$SWITCHREPO_PROJ missing. Please set Azure DevOps Project for Repos e.g. export SWITCHREPO_PROJ=myproject'
          return
        fi
        if  [ ! -n "${SWITCHREPO_PAT}" ]; then
          echo '$SWITCHREPO_PAT missing. Please set Azure DevOps PAT for Repos e.g. export SWITCHREPO_PAT=XYZ'
          return
        fi
       

       base64AuthInfo="$(echo -n Username:$SWITCHREPO_PAT | base64)"

      responsecode=$(curl --request GET \
      --write-out '%{http_code}' \
        --url "https://dev.azure.com/$SWITCHREPO_ORG/$SWITCHREPO_PROJ/_apis/git/repositories?api-version=7.0" \
        --header 'Content-Type: application/json' \
        --header "Authorization: Basic $base64AuthInfo"\
        --header 'Cache-Control: no-cache' \
        --header 'Connection: keep-alive' \
        --header 'Host: dev.azure.com' \
        --header 'cache-control: no-cache' \
        --silent \
        --output $ZSH/repos.json)

        
        if [[ $responsecode -ne 200 ]]; then
          echo "Error in connecting to Azure DevOps. Please check your configured PAT."
          return
        fi

        search=$(echo "$1" | awk '{print tolower($0)}')
        filtered=$(jq --arg SEARCH "$search" '[.value[] | select(.name | ascii_downcase | contains ($SEARCH)) | .webUrl]' $ZSH/repos.json)
        filteredNames=$(jq --arg SEARCH "$search" '[.value[] | select(.name | ascii_downcase | contains ($SEARCH)) | .name]' $ZSH/repos.json)
        filteredDirs=()
   
        for d in $SWITCHREPO_WORKROOT*/; 
        do
            
            dirName=$(basename "$d")
            dirNameLower=$(echo "$dirName" | awk '{print tolower($0)}')
           
            if [[ $dirNameLower == *"$search"* ]]; then
           
              filteredDirs+=($dirName)
            fi
            
        done  
       
        filteredList=()
        selectList=()

        for row in $(echo "$filtered" | jq -r '.[]'); do
            repo=$(echo "$row" | sed 's:.*/::')
            url=$(echo "$row")
            filteredList+=("$url")
            selectList+=("$repo")
        done

        for dir in "${filteredDirs[@]}"; do
            # if not contains
            if [[ ! " ${selectList[@]} " =~ " ${dir} " ]]; then
               selectList+=("$dir")
            fi
        done
        if [ ${#selectList[@]} -lt 1 ]; then
          echo "No Repositories found!"
          return
        fi
        if [ ${#selectList[@]} -eq 1 ]; then
                 echo "Only one repository found: ${selectList[@]}"
                 repository="${selectList[@]}"

        else
                PS3="Select Repository: "
                select repository in "${selectList[@]}"
                do
                    echo "Selected repository: $repository"
                    break
                done
        fi
        DIR="$SWITCHREPO_WORKROOT$repository/"
        if [ -d "$DIR" ]; then
        # Take action if $DIR exists. #
          pushd $DIR > /dev/null
          #git fetch --prune > /dev/null
          git pull 
        else
          pushd $SWITCHREPO_WORKROOT > /dev/null
          for i in "${filteredList[@]}"
          do
            if [[ "$i" == *"$repository" ]]
            then
              git clone $i > /dev/null
              pushd $DIR > /dev/null
              break
            fi
          done
        fi
    else
        echo "Usage : sr <repo name>"
        echo "Example : sr banana"
    fi
}


alias sr='switch-repo'
