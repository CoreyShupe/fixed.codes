<template>
    <nuxt-link :to="path" id="clickable" class="content nav-item">
        <span class="material-icons" style="margin-right: 4px">{{ icon }}</span>
        {{ text }}
    </nuxt-link>
</template>

<script>
export default {
    props: ["icon", "text", "path"],
    name: "IconLink",
}
</script>