<script>
	import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	export let data;
</script>

<EvidenceDefaultLayout {data} logo=/mle_banner_logo.png githubRepo=https://github.com/Minor-League-Esports/evidence xProfile=https://twitter.com/MLEsportsGG fullWidth=true >
	<slot slot="content" />
</EvidenceDefaultLayout>
