// Copyright (C) 2013-2025 Michael Kazakov. Subject to GNU General Public License version 3.
#pragma once

#include <Cocoa/Cocoa.h>
#include <functional>
#include <string>
#include <Base/Error.h>
#include <expected>

@class PanelController;

@interface GoToFolderSheetController : NSWindowController <NSTextFieldDelegate>

@property(nonatomic) PanelController *panel;
@property(nonatomic, readonly) const std::string &requestedPath;

// If set before the sheet is shown, the text field is pre-populated with this path instead of the
// last path used previously.
@property(nonatomic) NSString *initialPath;

- (void)showSheetWithParentWindow:(NSWindow *)_window handler:(std::function<void()>)_handler;
- (void)tellLoadingResult:(const std::expected<void, nc::Error> &)_result;

@end
