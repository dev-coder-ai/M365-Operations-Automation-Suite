# Request Hub — Power Apps canvas app

A lightweight front end so staff can submit and track requests without using Forms. Source lives in `src/` as Power Fx YAML and packs to `RequestHub.msapp` with the Power Platform CLI.

## Pack / unpack

```
pac canvas pack   --msapp RequestHub.msapp --sources ./src
pac canvas unpack --msapp RequestHub.msapp --sources ./src
```

## Screen: Request Hub

- **Submit form** bound to the `Purchase Requests` SharePoint list (`FormMode.New`). `SubmitForm` on the button, with success/error `Notify` toasts and `ResetForm`.
- **My recent requests gallery** filtered to the signed-in user (`Requestor = User().Email`), sorted newest first, with a colour-coded status badge (amber Pending, green Approved, red Rejected) driven by a `Switch` on `Status.Value`.
- **OnStart** caches the current user and brand colours into globals.

## How it fits the suite

The app writes to the same list the approval flow reads, so a submission through Request Hub triggers nothing extra — the flow can be set to trigger on item creation, or the team can keep the Forms trigger and use the app purely for tracking. Either way the back end is unchanged.
