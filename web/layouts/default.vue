<template>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin=""/>
  <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans&display=swap" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"/>
  <div class="header">
    <!-- Put in personal header; potentially branding picture -->
    <div class="header_branding">
      <img class="header_content"
           :src="`/brand/branding_skin.png`"
           alt="BTag"
           width="44"
           height="44"
      />
    </div>
    <SiteNavigation/>
  </div>
  <main>
    <slot/>
  </main>
</template>
