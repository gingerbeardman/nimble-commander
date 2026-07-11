// Copyright (C) 2026 Michael Kazakov. Subject to GNU General Public License version 3.
#include "ShowFileInfo.h"
#include <Base/dispatch_cpp.h>
#include <VFS/VFS.h>
#include "../PanelController.h"
#include "../PanelView.h"
#include <Panel/PanelData.h>
#include <Utility/StringExtras.h>

namespace nc::panel::actions {

// Collects the native filesystem paths of the items that "Get Info" should be shown for.
// Get Info is a Finder feature, so it only makes sense for items residing on the native filesystem.
static std::vector<std::string> NativePaths(PanelController *_target)
{
    std::vector<std::string> paths;
    for( const VFSListingItem &item : _target.selectedEntriesOrFocusedEntry ) {
        if( !item || item.IsDotDot() )
            continue;
        if( !item.Host()->IsNativeFS() )
            continue;
        paths.emplace_back(item.Path());
    }
    return paths;
}

bool ShowFileInfo::Predicate(PanelController *_target) const
{
    return !NativePaths(_target).empty();
}

void ShowFileInfo::Perform(PanelController *_target, [[maybe_unused]] id _sender) const
{
    const std::vector<std::string> paths = NativePaths(_target);
    if( paths.empty() )
        return;

    // There's no AppKit/NSWorkspace API to open Finder's "Get Info" window - NSWorkspace can only
    // reveal items. Apple Events is the only documented route, so ask Finder to open an information
    // window per file. This mirrors Finder's own Cmd+I: one window per selected item.
    NSMutableString *const source = [NSMutableString stringWithString:@"tell application \"Finder\"\nactivate\n"];
    for( const std::string &path : paths ) {
        NSString *const p = [NSString stringWithUTF8StdString:path];
        NSString *const escaped = [[p stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
            stringByReplacingOccurrencesOfString:@"\""
                                      withString:@"\\\""];
        [source appendFormat:@"open information window of (POSIX file \"%@\" as alias)\n", escaped];
    }
    [source appendString:@"end tell\n"];

    // Sending the Apple Event can block while Finder responds, and may show an automation-permission
    // prompt on first use, so perform it off the main thread.
    dispatch_to_background([source] {
        NSAppleScript *const script = [[NSAppleScript alloc] initWithSource:source];
        NSDictionary *error = nil;
        [script executeAndReturnError:&error];
        if( error )
            NSLog(@"ShowFileInfo: failed to open Finder Get Info window: %@", error);
    });
}

} // namespace nc::panel::actions
