# Date Added song sorting

Songs now carry Android MediaStore `DATE_ADDED` metadata. The default song order is **Date added (newest first)**.

The Songs sort picker also provides **Date added (oldest first)**. The selected sort remains persisted through the existing SettingsRepository/Hive settings.

The MediaStore query itself is also ordered newest-first, so a fresh scan naturally returns the newest additions first before the Flutter sort is applied.
