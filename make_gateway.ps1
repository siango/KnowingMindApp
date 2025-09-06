param(
  [Parameter(Mandatory=$true)][string]$Mode,     # webhook | start | stop | run
  [string]$WebhookUrl,
  [string]$ApiBase = "https://us1.make.com/api/v2",
  [string]$ApiKey,
  [int]$ScenarioId,
  [string]$JsonData
)

function PostJson($url, $body, $headers){
  Invoke-RestMethod -Method Post -Uri $url -Headers $headers -ContentType "application/json" -Body $body
}

switch ($Mode) {
  "webhook" {
    if(-not $WebhookUrl){ throw "WebhookUrl required" }
    $body = if($JsonData){ $JsonData } else { "{}" }
    Invoke-RestMethod -Method Post -Uri $WebhookUrl -ContentType "application/json" -Body $body
  }
  "start" {
    if(-not $ApiKey -or -not $ScenarioId){ throw "ApiKey & ScenarioId required" }
    $h = @{ Authorization = $ApiKey }
    PostJson "$ApiBase/scenarios/$ScenarioId/start" "{}" $h
  }
  "stop" {
    if(-not $ApiKey -or -not $ScenarioId){ throw "ApiKey & ScenarioId required" }
    $h = @{ Authorization = $ApiKey }
    PostJson "$ApiBase/scenarios/$ScenarioId/stop" "{}" $h
  }
  "run" {
    if(-not $ApiKey -or -not $ScenarioId){ throw "ApiKey & ScenarioId required" }
    $h = @{ Authorization = $ApiKey }
    $body = if($JsonData){ $JsonData } else { '{"responsive":true,"data":{}}' }
    PostJson "$ApiBase/scenarios/$ScenarioId/run" $body $h
  }
  default { throw "Unknown Mode: $Mode" }
}
