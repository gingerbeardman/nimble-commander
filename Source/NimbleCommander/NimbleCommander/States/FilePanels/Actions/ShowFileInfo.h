// Copyright (C) 2026 Michael Kazakov. Subject to GNU General Public License version 3.
#pragma once

#include "DefaultAction.h"

namespace nc::panel::actions {

// Opens Finder's "Get Info" window for each selected native file.
struct ShowFileInfo final : PanelAction {
    [[nodiscard]] bool Predicate(PanelController *_target) const override;
    void Perform(PanelController *_target, id _sender) const override;
};

} // namespace nc::panel::actions
