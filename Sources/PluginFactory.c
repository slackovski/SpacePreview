/*
 * PluginFactory.c
 *
 * The Quick Look daemon uses the CFPlugin model to load generators.
 * It looks for `QuickLookGeneratorPluginFactory`, which must return a pointer
 * to a QLGeneratorInterfaceStruct. Without this entry point (and the matching
 * CFPlugin keys in Info.plist), the daemon refuses to load the bundle.
 *
 * The actual preview logic lives in Swift; this file just wires up the
 * C function-pointer table and the plugin factory.
 */

#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFPlugInCOM.h>
#include <QuickLook/QLGenerator.h>

/* ── Forward declarations for Swift-exported functions ──────────────────── */

extern OSStatus GeneratePreviewForURL(
    QLPreviewRequestRef preview,
    CFURLRef            url,
    CFStringRef         contentTypeUTI,
    CFDictionaryRef     options
);

extern void CancelPreviewGeneration(QLPreviewRequestRef preview);

/* ── IUnknown stubs (QL doesn't actually use COM ref-counting) ──────────── */

static HRESULT pluginQueryInterface(void *self, REFIID iid, LPVOID *ppv) {
    (void)self; (void)iid; (void)ppv;
    return E_NOINTERFACE;
}
static ULONG pluginAddRef(void *self)  { (void)self; return 1; }
static ULONG pluginRelease(void *self) { (void)self; return 1; }

/* ── Wrapper functions that drop the "thisInterface" first argument ──────── */

static OSStatus wrapGeneratePreviewForURL(
    void               *thisInterface,
    QLPreviewRequestRef preview,
    CFURLRef            url,
    CFStringRef         contentTypeUTI,
    CFDictionaryRef     options
) {
    (void)thisInterface;
    return GeneratePreviewForURL(preview, url, contentTypeUTI, options);
}

static void wrapCancelPreviewGeneration(
    void               *thisInterface,
    QLPreviewRequestRef preview
) {
    (void)thisInterface;
    CancelPreviewGeneration(preview);
}

/* ── Static interface struct ─────────────────────────────────────────────── */

static QLGeneratorInterfaceStruct gQLInterface = {
    NULL,                           /* _reserved          */
    pluginQueryInterface,           /* QueryInterface     */
    pluginAddRef,                   /* AddRef             */
    pluginRelease,                  /* Release            */
    NULL,                           /* GenerateThumbnailForURL   (not implemented) */
    NULL,                           /* CancelThumbnailGeneration (not implemented) */
    wrapGeneratePreviewForURL,      /* GeneratePreviewForURL     */
    wrapCancelPreviewGeneration,    /* CancelPreviewGeneration   */
};

/* ── Plugin factory ──────────────────────────────────────────────────────── */

void *QuickLookGeneratorPluginFactory(CFAllocatorRef allocator, CFUUIDRef typeID) {
    (void)allocator;
    if (CFEqual(typeID, kQLGeneratorTypeID)) {
        return (void *)&gQLInterface;
    }
    return NULL;
}
