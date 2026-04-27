---
title: MLE Champions
---

```sql teamLogos
SELECT 
franchise,
'/franchises/' || franchise as franchiseLink,
"Photo URL" as logo
FROM teams
ORDER BY franchise ASC
```

<h2 style="font-size: 25px;"><center><b><u> Season 18 Champions </u></b></center></h2>

<h3 style="font-size: 20px;"><center><b> Doubles: </b></center></h3>

<div style="text-align: center;">
    <span style="display: inline-flex; align-items: center;">
        <b>FL:</b> &nbsp;Flames {#if teamLogos?.[11]?.logo}<img class="h-10" alt="Flames" style="content: url('{teamLogos[11].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>AL:</b> &nbsp;Hurricanes {#if teamLogos?.[15]?.logo}<img class="h-10" alt="Hurricanes" style="content: url('{teamLogos[15].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>CL:</b> &nbsp;Tyrants {#if teamLogos?.[29]?.logo}<img class="h-10" alt="Tyrants" style="content: url('{teamLogos[29].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>ML:</b> &nbsp;Ducks {#if teamLogos?.[7]?.logo}<img class="h-10" alt="Ducks" style="content: url('{teamLogos[7].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>PL:</b> &nbsp;Bulls {#if teamLogos?.[3]?.logo}<img class="h-10" alt="Bulls" style="content: url('{teamLogos[3].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
</div>

<h3 style="font-size: 20px;"><center><b> Standard: </b></center></h3>

<div style="text-align: center;">
    <span style="display: inline-flex; align-items: center;">
        <b>FL:</b> &nbsp;Flames {#if teamLogos?.[11]?.logo}<img class="h-10" alt="Flames" style="content: url('{teamLogos[11].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>AL:</b> &nbsp;Bulls {#if teamLogos?.[3]?.logo}<img class="h-10" alt="Bulls" style="content: url('{teamLogos[3].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>CL:</b> &nbsp;Flames {#if teamLogos?.[11]?.logo}<img class="h-10" alt="Flames" style="content: url('{teamLogos[11].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>ML:</b> &nbsp;Ducks {#if teamLogos?.[7]?.logo}<img class="h-10" alt="Ducks" style="content: url('{teamLogos[7].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>PL:</b> &nbsp;Shadow {#if teamLogos?.[25]?.logo}<img class="h-10" alt="Shadow" style="content: url('{teamLogos[25].logo}'); object-fit: contain; vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />{/if}
    </span>
</div>

<p style="text-align: center; color: gray; font-style: italic; margin-top: 2rem;">
    Previous season champions and full MLE history coming soon.
</p>
