-- a simplified version of the plugin. Only uses grayscale

local M = {}

function M:peek(job)
  local name = tostring(job.file.url)
  if not name:find("%.nii%.gz$") and not name:find("%.nii$") then return end

  local fsldir = os.getenv("FSLDIR") or ""
  local slicer_bin = fsldir .. "/bin/slicer"
  local out = "/tmp/yazi_nifti_preview.png"

  local ok = os.execute(
    string.format("%s %s -s 2 -a %s 2>/dev/null", slicer_bin, name, out)
  )

  if not ok then
    ya.err("nifti: slicer failed for " .. name)
    return
  end

  ya.image_show(Url(out), job.area)
end

function M:seek() end
return M
