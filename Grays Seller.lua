local _ = {}

local Coroutine = Library.retrieve("Coroutine", "^2.0.0")
local Compatibility = Library.retrieve("Compatibility", "^2.0.2")
local Events = Library.retrieve("Events", "^2.0.0")

local isMerchantOpen = false

local function onEvent(self, event, ...)
  if event == "MERCHANT_SHOW" then
    _.onMerchantShow(...)
  elseif event == "MERCHANT_CLOSED" then
    _.onMerchantClosed(...)
  end
end

function _.onMerchantShow()
  isMerchantOpen = true
  Coroutine.runAsCoroutine(_.sellItemsAtVendor)
end
function _.onMerchantClosed()
  isMerchantOpen = false
end
function _.sellItemsAtVendor()
  for containerIndex = 0, NUM_BAG_SLOTS do
    for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
      local itemInfo = Compatibility.Container.retrieveItemInfo(containerIndex,
        slotIndex)
      if itemInfo then
        local classID = select(6, GetItemInfoInstant(itemInfo.itemID))
        if itemInfo and
          not itemInfo.hasNoValue and
          itemInfo.quality == Enum.ItemQuality.Poor
        then
          if isMerchantOpen then
            Compatibility.Container.UseContainerItem(containerIndex, slotIndex)
            Events.waitForEvent("BAG_UPDATE_DELAYED")
          else
            return
          end
        end
      end
    end
  end
end
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", onEvent)
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
