local M = {}

function M:new(id)
    local progress_bar = {
        id = id,
        box_node = gui.get_node(id .. "_foreground"),
        text_node =  gui.get_node(id .. "_text"),
        progress = 0,
    }

    function progress_bar:update_progress(progress)
        self.progress = progress
        gui.set_scale(self.box_node, vmath.vector3( self.progress, 1, 1))
        progress_bar:set_text(string.format(self.id .. " %.0f%%" .. " processing",  self.progress * 100))
    end

    function progress_bar:animate_progress(progress)
        self.progress = progress
        gui.cancel_animation(self.box_node, gui.PROP_SCALE)
        gui.animate(self.box_node, gui.PROP_SCALE, vmath.vector3(self.progress, 1, 1), gui.EASING_INOUTSINE, 0.25, 0, function()
            progress_bar:set_text(string.format(self.id .. " %.0f%%" .. " processing",  self.progress * 100))
        end)
    end

    function progress_bar:set_text(text)
        gui.set_text(self.text_node, text)
    end

    function progress_bar:set_color(color)
        gui.set_color(gui.get_node(self.id), color)
    end

    return progress_bar
end

return M;
