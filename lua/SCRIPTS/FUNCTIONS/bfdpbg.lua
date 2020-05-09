local function background()
    if cmsMenuOpen == true and lastMenuEventTime + 100 < getTime() then
    displayPortCmd(CRSF_DISPLAYPORT_SUBCMD_CLOSE, nil)
    cmsMenuOpen = false
    end
end
