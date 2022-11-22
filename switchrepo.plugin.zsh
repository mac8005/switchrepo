function switch-repo(){
    if ! [ -z $1 ] ; then
        if  [ -n "${SWITCHREPO_WORKROOT}" ]; then
        else
          echo '$SWITCHREPO_WORKROOT missing. Please set Directory for Repos e.g. export SWITCHREPO_WORKROOT=/Users/massimo/repos'
          return
        fi
        if  [ -n "${SWITCHREPO_ORG}" ]; then
        else
          echo '$SWITCHREPO_ORG missing. Please set Azure DevOps Org for Repos e.g. export SWITCHREPO_ORG=myorg'
          return
        fi
        if  [ -n "${SWITCHREPO_PROJ}" ]; then
        else
          echo '$SWITCHREPO_PROJ missing. Please set Azure DevOps Project for Repos e.g. export SWITCHREPO_PROJ=myproject'
          return
        fi
        if  [ -n "${SWITCHREPO_PAT}" ]; then
        else
          echo '$SWITCHREPO_PAT missing. Please set Azure DevOps PAT for Repos e.g. export SWITCHREPO_PAT=XYZ'
          return
        fi
       

       base64AuthInfo="$(echo -n Username:$SWITCHREPO_PAT | base64)"

      responsecode=$(curl --request GET \
      --write-out '%{http_code}' \
        --url "https://dev.azure.com/$SWITCHREPO_ORG/$SWITCHREPO_PROJ/_apis/git/repositories?api-version=5.0" \
        --header 'Content-Type: application/json' \
        --header "Authorization: Basic $base64AuthInfo"\
        --header 'Cache-Control: no-cache' \
        --header 'Connection: keep-alive' \
        --header 'Host: dev.azure.com' \
        --header 'cache-control: no-cache' \
        --silent \
        --output repos.json)

        
        if [[ $responsecode -ne 200 ]]; then
          echo "Error in connecting to Azure DevOps. Please check your configured PAT."
          return
        fi

        webUrl=`cat repos.json | jq  "[.value[] | .webUrl]"`
        filteredList=()
        selectList=()
        for row in $(echo "$webUrl" | jq -r '.[]'); do
           
            repo=$(echo "$row" | sed 's:.*/::')
            url=$(echo "$row")
            search=$(echo "$1" | awk '{print tolower($0)}')
            repolower=$(echo "$repo" | awk '{print tolower($0)}' )

            if [[ $repolower == *"$search"* ]]; then
                filteredList+=("$url")
                selectList+=("$repo")
            fi
         
        done
        PS3="Select Repository: "
        select repository in "${selectList[@]}"
        do
            echo "Selected repository: $repository"
            break
        done
        DIR="$SWITCHREPO_WORKROOT$repository/"
        if [ -d "$DIR" ]; then
        # Take action if $DIR exists. #
          pushd $DIR > /dev/null
          git fetch --prune > /dev/null
          git pull > /dev/null
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
