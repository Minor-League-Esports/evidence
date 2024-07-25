<script>
	import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	export let data;
</script>

<EvidenceDefaultLayout {data} title="Minor League Esports" logo=/MLE4.png githubRepo=https://github.com/Minor-League-Esports/evidence xProfile=https://twitter.com/MLEsportsGG >
	<slot slot="content" />
</EvidenceDefaultLayout>
