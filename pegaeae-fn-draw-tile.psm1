# MIT License
# Copyright (c) 2020 pegaeae

function Get-Tile {
    param (
        [string]   $tileID,
        [string]   $title,
        [datetime] $startDate,
        [datetime] $dueDate,
        [string]   $desc,
        [int]      $progress,
        [int]      $width,
        [int]      $progressWidth,
        [int]      $height,
        [string]   $imgDir
    )

    begin {

        $days = ($dueDate-[datetime]::Now).Days

        Add-Type -AssemblyName System.Drawing
        $filename = "$imgDir\$TileID.png"
        
        $titleFont    = new-object System.Drawing.Font Tahoma,12
        $daysFont     = new-object System.Drawing.Font Tahoma,8
        $progressFont = new-object System.Drawing.Font Tahoma,14

        $brushTileBg     = [System.Drawing.Brushes]::Transparent

        $brushTitleBg    = [System.Drawing.Brushes]::Transparent
        $brushDaysBg     = [System.Drawing.Brushes]::Transparent
        $brushProgressBg1 = [System.Drawing.Brushes]::Gray
        $brushProgressBg2 = [System.Drawing.Brushes]::Transparent

        $brushTitleFg    = [System.Drawing.Brushes]::Ivory
        $brushDaysFg     = [System.Drawing.Brushes]::DarkGoldenrod
        $brushProgressFg1= [System.Drawing.Brushes]::DarkSlateGray
        $brushProgressFg2= [System.Drawing.Brushes]::Ivory
        $brushErrorFg    = [System.Drawing.Brushes]::Fuchsia

        #string formats
        $titleFormat = new-object System.Drawing.StringFormat
        $titleFormat.Alignment = [System.Drawing.StringAlignment]::Far
        $titleFormat.LineAlignment = [System.Drawing.StringAlignment]::Far

        $daysFormat = new-object System.Drawing.StringFormat
        $daysFormat.Alignment = [System.Drawing.StringAlignment]::Far
        $daysFormat.LineAlignment = [System.Drawing.StringAlignment]::Near

        $progressFormat = new-object System.Drawing.StringFormat
        $progressFormat.Alignment = [System.Drawing.StringAlignment]::Far
        $progressFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

        #set drawing regions
        $midX = $width - (1 + $progressWidth + 1);

        $tileRect           = [System.Drawing.RectangleF]::FromLTRB( 1, 1, $Width - 1, $Height - 1)
            
            #get font size
            $font_size = [System.Windows.Forms.TextRenderer]::MeasureText($title, $titleFont)
            $w = $font_size.Width
            $h = $font_size.Height

        $titleRect          = [System.Drawing.RectangleF]::FromLTRB( 2, 2, $midX - 1, 2 + $h)
            #get font size
            $font_size = [System.Windows.Forms.TextRenderer]::MeasureText("$days jours de retard", $daysFont)
            $w = $font_size.Width
            $h = $font_size.Height
        $daysRect           = [System.Drawing.RectangleF]::FromLTRB( 2, ($height-2) - $h, $midX - 1,($height-2))
        
        $progressRect       = [System.Drawing.RectangleF]::FromLTRB( $midX + 1, 2, $midX + (1 + $progressWidth), $Height-2)
        $progressRectBorder = [System.Drawing.Rectangle ]::FromLTRB( $progressRect.left,$progressRect.top,$progressRect.right,$progressRect.bottom)
        $progressFilledRect = [System.Drawing.RectangleF]::FromLTRB( $progressRect.left + 1, $progressRect.top + 1,  `
            $progressRect.left + 1 + $progress * (-1 + $progressRect.Width - 1) / 100,
            $progressRect.bottom - 1)
        
        #set line position
        $progressTheo = ([datetime]::Now - $startDate).TotalHours / ($dueDate-$startDate).TotalHours;
        if ($progressTheo -gt 1) { $progressTheo = 1}
        if ($progressTheo -lt 0) { $progressTheo = 0}
        $progressTheo = $progressTheo * ($progressRect.Width-2)
        $progressLinePt1  = new-object System.Drawing.PointF(($progressRect.Left + 1 + $progressTheo),($progressRect.Top + 1))
        $progressLinePt2  = new-object System.Drawing.PointF($progressLinePt1.X,($progressRect.Bottom-1))

        #graph init
        $bmp = new-object System.Drawing.Bitmap $Width,$Height
        $graphics = [System.Drawing.Graphics]::FromImage($bmp)
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
        #make tile
        $graphics.FillRectangle($brushTileBg,$tileRect)
        
        #make title
        $graphics.FillRectangle($brushTitleBg,$titleRect)
        
        $graphics.DrawString($title, $titleFont, $brushTitleFg, $titleRect, $titleFormat)
        
        #make days
        if ($days -gt 0) {
            $graphics.DrawString("$days jours", $daysFont, $brushDaysFg, $daysRect, $daysFormat)
        } else {
            $graphics.DrawString("$(-$days) jours de retard", $daysFont, $brushErrorFg, $daysRect, $daysFormat)
        }

        #make progress
        $graphics.FillRectangle($brushProgressBg2,$progressRect)
        $graphics.DrawRectangle($brushProgressBg1,$progressRectBorder)
        $graphics.FillRectangle($brushProgressFg1,$progressFilledRect)
        
        if (($startDate -gt ([datetime]'1970-01-01Z')) -and ($dueDate -gt ([datetime]'1970-01-01Z'))) {
            if ($progressLinePt1.X -le $progressFilledRect.Right) {
                $graphics.DrawLine($brushProgressFg2,$progressLinePt1,$progressLinePt2)
            } else {
                $graphics.DrawLine($brushErrorFg,$progressLinePt1,$progressLinePt2)
            }
        }

        $graphics.DrawString("$progress%", $progressFont, $brushProgressFg2, $progressRect, $progressFormat)
        
    }
    process {
        

        #$graphics.FillRectangle($brushBg,0,0,$bmp.Width,$bmp.Height) 
        #$graphics.DrawString('Hello World',$font,$brushFg,10,10) 
    }
    end {
        $graphics.Dispose()
        $bmp.Save($filename)
        return $bmp
    }
}


