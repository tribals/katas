let liveTabs = []
let deadTabs = {}


function found(arr, e) {
  return arr.indexOf(e) > 0
}

function handleTabUpdated(tabId, changeInfo, tab) {
  if (changeInfo.status != chrome.tabs.TabStatus.COMPLETE) {
    return
  }

  let url = tab.url

  if (url) {
    if (found(liveTabs, url)) {
      if (!deadTabs[tab.url]) {
        deadTabs[tab.url] = []
      }
      deadTabs[tab.url].push(tab.id)
    } else {
      liveTabs.push(url)
    }
  }
}

chrome.tabs.onUpdated.addListener(handleTabUpdated)

function handleActionClicked(tab) {
  let killed = 0

  if (!deadTabs[tab.url]) {
    return
  }
  for (tabId of deadTabs[tab.url]) {
    chrome.tabs.remove(tabId)
    killed += 1
  } 
  deadTabs[tab.url] = []
  chrome.action.setBadgeText({text: killed.toString()})
}

chrome.action.onClicked.addListener(handleActionClicked)
