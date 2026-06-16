-- nifti.yazi — NIfTI previewer plugin for Yazi
--
-- LC 2026-04-27
--
-- Requirements:
--   - FSL installed with $FSLDIR set ($FSLDIR/bin/slicer must exist)
--   - A terminal with image support (Kitty, iTerm2, WezTerm, Ghostty...)
--
-- Configuration (~/.config/yazi/yazi.toml):
--   [[plugin.prepend_previewers]]
--   name = "*.nii.gz"
--   mime = "application/gzip"
--   run  = "nifti"
--
--   [[plugin.prepend_previewers]]
--   name = "*.nii"
--   mime = "application/octet-stream"
--   run  = "nifti"
--
-- Usage:
--   Hover over a .nii or .nii.gz file to preview brain slices.
--   Shift+J / Shift+K  cycle through colormaps (grayscale, hot, cool, green)



local M = {}

local LUTS = {
  nil,        -- grayscale (default)
  "render1",  
  "render2",  
  "render3",  
}

function M:peek(job)
  local name = tostring(job.file.url)
  if not name:find("%.nii%.gz$") and not name:find("%.nii$") then return end

  local fsldir = os.getenv("FSLDIR") or ""
  local slicer_bin = fsldir .. "/bin/slicer"
  local out = "/tmp/yazi_nifti_preview.png"

  -- Check FSL is available; show bundled image if not
  local slicer_check = io.open(slicer_bin, "r")
  if not slicer_check then
    local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
    local fsl_img = config_home .. "/yazi/plugins/nifti.yazi/fsl_not_found.png"
    ya.image_show(Url(fsl_img), job.area)
    return
  end
  slicer_check:close()

  local n = #LUTS
  local lut = LUTS[(job.skip % n) + 1]

  local cmd
  if lut then
    local lut_path = fsldir .. "/etc/luts/" .. lut .. ".lut"
    cmd = string.format("%s %s -l %s -s 2 -a %s 2>/dev/null",
      slicer_bin, name, lut_path, out)
  else
    cmd = string.format("%s %s -s 2 -a %s 2>/dev/null",
      slicer_bin, name, out)
  end

  local ok = os.execute(cmd)
  if not ok then
    ya.err("nifti: slicer failed for " .. name)
    return
  end

  ya.image_show(Url(out), job.area)
end

function M:seek(job)
  local h = cx.active.current.hovered
  if h and h.url == job.file.url then
    local n = #LUTS
    local current_skip = cx.active.preview.skip
    local new_skip = ((current_skip + job.units) % n + n) % n
    ya.mgr_emit("peek", { new_skip, only_if = job.file.url })
  end
end


return M
