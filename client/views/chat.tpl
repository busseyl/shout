{{#each channels}}
<div id="chan-{{id}}" data-title="{{name}}" data-id="{{id}}" data-type="{{type}}" class="chan {{type}}">
	<div class="header">
		<button class="lt"></button>
		<button class="rt"></button>
		<div class="right">
			<button class="button close">
				{{#equal type "lobby"}}
					Disconnect
				{{else}}
					{{#equal type "query"}}
						Close
					{{else}}
						Leave
					{{/equal}}
				{{/equal}}
			</button>
		</div>
		<span class="title">{{name}}</span>
		<span class="topic">{{{parse topic}}}</span>
	</div>
	{{#equal type "query"}}
	<div class="rtc" style="display: none;">
		<div class="remoteVideo">
			<video id="remoteVideo-{{id}}" height="100%" width="100%"></video>
			<audio id="remoteAudio-{{id}}" style="display: none;"></audio>
		</div>
		<div class="localVideo">
			<video id="localVideo-{{id}}" height="100%" width="100%" muted="muted"></video>
			<audio id="localAudio-{{id}}" style="display: none;" muted="muted"></audio>
		</div>
	</div>
	{{/equal}}
	<div class="chat">
		<div class="show-more {{#equal messages.length 100}}show{{/equal}}">
			<button class="show-more-button" data-id="{{id}}">
				Show more
			</button>
		</div>
		<div class="messages"></div>
	</div>
	<aside class="sidebar">
		<div class="users">
			{{partial "user"}}
		</div>
	</aside>
</div>
{{/each}}
