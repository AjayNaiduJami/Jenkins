$JENKINS_SERVER_IP=""
$USERNAME=""
$PASSWORD=""
$NODE_NAME="windows_test_node"
$NUM_EXECUTORS=2


$NODE_SLAVE_HOME="C:\Jenkins"
$JENKINS_URL="http://${JENKINS_SERVER_IP}"
$AUTH = -join ("$USERNAME", ":", "$PASSWORD")

function Slave-Setup()
{

    New-Item -ItemType Directory -Force -Path $NODE_SLAVE_HOME
    Write-Host "Downloading jenkins-cli.jar file"
    (New-Object System.Net.WebClient).DownloadFile("$JENKINS_URL/jnlpJars/jenkins-cli.jar", "$NODE_SLAVE_HOME\jenkins-cli.jar")

    Write-Host "Downloading slave.jar file"
    (New-Object System.Net.WebClient).DownloadFile("$JENKINS_URL/jnlpJars/slave.jar", "$NODE_SLAVE_HOME\slave.jar")

# Generating node.xml for creating node on Jenkins server
  $NodeXml = @"
<slave>
<name>$NODE_NAME</name>
<description>Windows Slave</description>
<remoteFS>$NODE_SLAVE_HOME</remoteFS>
<numExecutors>$NUM_EXECUTORS</numExecutors>
<mode>NORMAL</mode>
<retentionStrategy class="hudson.slaves.RetentionStrategy`$Always`"/>
<launcher class="hudson.slaves.JNLPLauncher">
  <workDirSettings>
    <disabled>false</disabled>
    <internalDir>remoting</internalDir>
    <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
  </workDirSettings>
</launcher>
<label>$NODE_NAME</label>
<nodeProperties/>
</slave>
"@
  $NodeXml | Out-File -FilePath $NODE_SLAVE_HOME\node.xml 

  # Creating node using node.xml
  Write-Host "Creating $NODE_NAME"
  Get-Content -Path $NODE_SLAVE_HOME\node.xml | java -jar $NODE_SLAVE_HOME\jenkins-cli.jar -s $JENKINS_URL -auth $AUTH create-node $NODE_NAME
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip()
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function Create-Service()
{
    Write-Host "Downloading NSSM and creating service for jenkins worker node"
    (New-Object System.Net.WebClient).DownloadFile("https://nssm.cc/release/nssm-2.24.zip", "$NODE_SLAVE_HOME\nssm-2.24.zip")
    Unzip "$NODE_SLAVE_HOME\nssm-2.24.zip" "$NODE_SLAVE_HOME"
    Start-Process -FilePath "$NODE_SLAVE_HOME\nssm-2.24\win64\nssm" -ArgumentList "install Jenkins_Agent java -jar $NODE_SLAVE_HOME\slave.jar -jnlpCredentials $AUTH -jnlpUrl $JENKINS_URL/computer/$NODE_NAME/slave-agent.jnlp -workDir $NODE_SLAVE_HOME"
    Start-Process -FilePath "$NODE_SLAVE_HOME\nssm-2.24\win64\nssm" -ArgumentList "set TestServ DisplayName Jenkins_Agent"
    Start-Process -FilePath "$NODE_SLAVE_HOME\nssm-2.24\win64\nssm" -ArgumentList "set TestServ Description Service for running Jenkins Slave agent JNLP jar"
    Start-Process -FilePath "$NODE_SLAVE_HOME\nssm-2.24\win64\nssm" -ArgumentList "start Jenkins_Agent"
    Write-Host "Registering Node $NODE_NAME via JNLP"
}


Slave-Setup
Create-Service


Write-Host "Done"